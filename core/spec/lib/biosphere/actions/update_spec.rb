require 'spec_helper'
require 'biosphere/actions/update'

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

    context 'updating a specific sphere' do
      it '' do
        sphere = Biosphere::Resources::Sphere.new('test1').create!
        sphere = Biosphere::Resources::Sphere.new('test2').create!

        described_class.new(['test1']).call
      end
    end

    context 'help' do
      it 'shows the help' do
        allow(Biosphere::Runtime).to receive(:help_mode?).and_return true
        described_class.new.call
      end
    end
  end


  #context 'no arguments' do
  #  describe '.perform' do
  #    it 'updates all spheres and triggers a global reactivation' do
  #      expect(Biosphere::Resources::Sphere).to receive(:all).with(no_args()).and_return spheres
  #      expect(sphere1).to receive(:update).with(no_args())
  #      expect(sphere2).to receive(:update).with(no_args())
  #      expect(sphere3).to receive(:update).with(no_args())
  #      expect(Biosphere::Action).to receive(:perform).with(%w{ activate })
  #      action.perform
  #    end
  #  end
  #end

 #context 'with arguments' do
 #  before do
 #    @args = %w{ project work }
 #  end
 #
 #  describe '.perform' do
 #    it 'updates the specified spheres and triggers a global reactivation' do
 #      expect(Biosphere::Resources::Sphere).to receive(:find).with('work').and_return sphere1
 #      expect(Biosphere::Resources::Sphere).to receive(:find).with('project').and_return sphere3
 #      expect(sphere1).to receive(:update).with(no_args())
 #      expect(sphere3).to receive(:update).with(no_args())
 #      expect(Biosphere::Action).to receive(:perform).with(%w{ activate })
 #      action.perform
 #    end
 #  end
 #end

end
