require 'spec_helper'
require 'biosphere/actions/update'

RSpec.describe Biosphere::Actions::Update do

  describe 'call' do
    context 'updating the biosphere system core' do
      it 'uses git to update the repository' do
        system %(cd #{Biosphere::Paths.biosphere_home} && git init > /dev/null)
        system %(cd #{Biosphere::Paths.biosphere_home} && git remote add origin remote.example.com)

        lines = []
        allow(Biosphere::Log).to receive(:info) do |*args, &block|
          expect(args).to be_empty
          lines << block.call
          expect(lines.last).to include %(does not appear to be a git repository) if lines.size == 1
        end

        expect { described_class.new(['--system']).call }.to raise_error Biosphere::Errors::CouldNotUpdateBiosphere
      end
    end

    context 'updating the sphere' do
      it '' do
        described_class.new.call
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
