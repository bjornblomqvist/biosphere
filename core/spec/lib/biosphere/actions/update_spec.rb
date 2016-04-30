require 'spec_helper'
require 'biosphere/actions/update'
require 'biosphere/managers/chefsolo'

RSpec.describe Biosphere::Actions::Update do

  describe 'call' do
    context 'updating biosphere core fails' do
      it 'uses git to update the repository' do
        system %(cd #{Biosphere::Paths.biosphere_home} && git init > /dev/null)
        system %(cd #{Biosphere::Paths.biosphere_home} && git remote add origin remote.example.com)

        lines = []
        allow(Biosphere::Log).to receive(:info) do |*args, &block|
          expect(args).to be_empty
          lines << block.call
          expect(lines.last).to include %(remote.example.com' does not appear to be a git repository) if lines.size == 1
        end

        expect { described_class.new(['--system']).call }.to raise_error Biosphere::Errors::CouldNotUpdateBiosphere
      end
    end

    context 'updating biosphere core succeeds' do
      it 'succeeds' do
        action = described_class.new(['--system'])
        dummy_command = Biosphere::Resources::Command.new executable: 'whoami'
        allow(action).to receive(:update_command).and_return dummy_command

        lines = []
        allow(Biosphere::Log).to receive(:info) do |*args, &block|
          expect(args).to be_empty
          lines << block.call
          expect(lines.last).to include %(Biosphere was updated) if lines.size == 1
        end

        action.call
      end
    end

    context 'updating a specific manual sphere' do
      it 'does nothing' do
        sphere = Biosphere::Resources::Sphere.new('test1').create!

        described_class.new(['test1']).call
      end
    end

    context 'updating a specific sphere with remote cookbooks fail' do
      it 'raises an error' do
        sphere = Biosphere::Resources::Sphere.new('test1').create!
        gem_installer = double(:gem_installer)
        allow(gem_installer).to receive(:call).and_return true
        allow(gem_installer).to receive(:executables_path).and_return Pathname.new('/dev/null/gems_executables')
        allow(Biosphere::Resources::Gem).to receive(:new).and_return gem_installer
        config_file = sphere.send(:config_file_path)
        config_file.open('w') { |io| io.write "manager:\n  chefsolo:\n    cookbooks_repo: /dev/null/remote.git\n    cookbooks_path: example" }

        expect { described_class.new(['test1']).call }.to raise_error Biosphere::Errors::CouldNotCloneRemoteCookbooks
      end
    end

    context 'help' do
      it 'shows the help' do
        allow(Biosphere::Runtime).to receive(:help_mode?).and_return true
        described_class.new.call
      end
    end

    context 'there are no spheres' do
      it 'does nothing' do
        lines = []
        allow(Biosphere::Log).to receive(:info) do |*args, &block|
          expect(args).to be_empty
          lines << block.call
          expect(lines.last).to include %(You have no Spheres) if lines.size == 1
        end

        described_class.new().call
      end
    end

    context 'specified sphere does not exist' do
      it 'raises an error' do
        lines = []
        allow(Biosphere::Log).to receive(:info) do |*args, &block|
          expect(args).to be_empty
          lines << block.call
          expect(lines.last).to include %(does not exist) if lines.size == 1
        end

        expect { described_class.new(['notyou']).call }.to raise_error Biosphere::Errors::SphereNotFound
      end
    end
  end

end
