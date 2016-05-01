require 'spec_helper'
require 'biosphere/managers/chefsolos/remote_cookbooks'
require 'biosphere/resources/sphere'

RSpec.describe Biosphere::Managers::Chefsolos::RemoteCookbooks do

  describe '#call' do
    context 'no remote specified' do
      it 'does nothing' do
        sphere = Biosphere::Resources::Sphere.new('test1')
        instance = described_class.new sphere: sphere, config: OpenStruct.new

        expect(Biosphere::Log).to receive(:debug) do |*args, &block|
          expect(args).to be_empty
          expect(block.call).to eq 'Your sphere.yml does not specify `cookbooks_repo:` so there are no remote cookbooks to sync with.'
        end

        expect(Biosphere::Log).to_not receive(:info)
        expect(Biosphere::Log).to_not receive(:error)

        instance.call
      end
    end

    context 'local does not exist yet' do
      it 'clones the remote cookbooks' do
        sphere = Biosphere::Resources::Sphere.new('test1')
        config = OpenStruct.new cookbooks_repo: '/dev/null/some/remote'
        instance = described_class.new sphere: sphere, config: config

        arguments = %W(clone /dev/null/some/remote #{sphere.path.join('cookbooks/some_remote')})
        attributes = { executable: :git, arguments: arguments }
        command = double(:command)
        expect(command).to receive(:call).and_return OpenStruct.new(success?: true)
        expect(Biosphere::Resources::Command).to receive(:new).with(attributes).and_return command

        expect(Biosphere::Log).to receive(:debug) do |*args, &block|
          expect(args).to be_empty
          expect(block.call).to eq 'Successfully cloned remote cookbooks.'
        end

        infos = []
        expect(Biosphere::Log).to receive(:info).twice do |*args, &block|
          expect(args).to be_empty
          infos << block.call
          expect(infos.last).to eq 'Cloning remote cookbooks from /dev/null/some/remote' if infos.size == 1
          expect(infos.last).to eq "Cloning into #{sphere.path.join('cookbooks/some_remote')}" if infos.size == 2
        end

        expect(Biosphere::Log).to_not receive(:error)

        instance.call
      end
    end

    context 'cloning fails' do
      it 'raises an error' do
        sphere = Biosphere::Resources::Sphere.new('test1')
        config = OpenStruct.new cookbooks_repo: '/dev/null/some/remote'
        instance = described_class.new sphere: sphere, config: config

        command = double(:command)
        expect(command).to receive(:call).and_return OpenStruct.new(success?: false)
        expect(Biosphere::Resources::Command).to receive(:new).and_return command

        expect(Biosphere::Log).to_not receive(:debug)

        infos = []
        expect(Biosphere::Log).to receive(:info).twice do |*args, &block|
          expect(args).to be_empty
          infos << block.call
          expect(infos.last).to eq 'Cloning remote cookbooks from /dev/null/some/remote' if infos.size == 1
          expect(infos.last).to eq "Cloning into #{sphere.path.join('cookbooks/some_remote')}" if infos.size == 2
        end

        expect(Biosphere::Log).to receive(:error) do |*args, &block|
          expect(args).to be_empty
          expect(block.call).to eq 'Failed to clone remote cookbooks. Use the --debug flag for more details.'.red
        end

        expect { instance.call }.to raise_error Biosphere::Errors::CouldNotCloneRemoteCookbooks
      end
    end
  end

  context 'local exists' do
    it 'synchronizes with the remote cookbooks' do
      sphere = Biosphere::Resources::Sphere.new('test1')
      config = OpenStruct.new cookbooks_repo: '/dev/null/some/remote'
      instance = described_class.new sphere: sphere, config: config
      local_path = sphere.path.join('cookbooks/some_remote')
      local_path.mkpath

      arguments = %W(--work-tree #{local_path} --git-dir #{local_path}/.git pull origin master)
      attributes = { executable: :git, arguments: arguments }
      command = double(:command)
      expect(command).to receive(:call).and_return OpenStruct.new(success?: true)
      expect(Biosphere::Resources::Command).to receive(:new).with(attributes).and_return command

      expect(Biosphere::Log).to_not receive(:debug)

      infos = []
      expect(Biosphere::Log).to receive(:info).twice do |*args, &block|
        expect(args).to be_empty
        infos << block.call
        expect(infos.last).to eq 'Updating remote cookbooks from /dev/null/some/remote' if infos.size == 1
        expect(infos.last).to eq 'Cookbooks successfully updated.' if infos.size == 2
      end

      expect(Biosphere::Log).to_not receive(:error)

      instance.call
    end
  end

  context 'synchronization of local fails' do
    it 'raises an error' do
      sphere = Biosphere::Resources::Sphere.new('test1')
      config = OpenStruct.new cookbooks_repo: '/dev/null/some/remote'
      instance = described_class.new sphere: sphere, config: config
      local_path = sphere.path.join('cookbooks/some_remote')
      local_path.mkpath

      command = double(:command)
      expect(command).to receive(:call).and_return OpenStruct.new(success?: false)
      expect(Biosphere::Resources::Command).to receive(:new).and_return command

      expect(Biosphere::Log).to_not receive(:debug)

      expect(Biosphere::Log).to receive(:info) do |*args, &block|
        expect(args).to be_empty
        expect(block.call).to eq 'Updating remote cookbooks from /dev/null/some/remote'
      end

      expect(Biosphere::Log).to receive(:error) do |*args, &block|
        expect(args).to be_empty
        expect(block.call).to eq 'Failed to update remote cookbooks. Use the --debug flag for more details.'.red
      end

      expect { instance.call }.to raise_error Biosphere::Errors::CouldNotUpdateRemoteCookbooks
    end
  end

end
