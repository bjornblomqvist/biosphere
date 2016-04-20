require 'spec_helper'
require 'biosphere/actions/activate'

RSpec.describe Biosphere::Actions::Activate do

  context 'no arguments, no spheres' do
    describe '.call' do
      it 'does nothing' do
        expect(Biosphere::Log).to receive(:info) do |*args, &block|
          expect(args).to be_empty
          expect(block.call).to include "No Sphere to activate."
        end

        #Biosphere::Paths.biosphere_home = Dir.mktmpdir
        #sphere = Biosphere::Resources::Sphere.new('work')
        #sphere.create!

        action = described_class.new #sphere: sphere
        action.call
      end
    end
  end

  #context 'with arguments' do
  #  before do
  #    @args = %w{ private project }
  #  end
  #
  #  describe '.call' do
  #    it 'activates the spheres and first deactivates all unused' do
  #      expect(Biosphere::Log).to receive(:info).with('Deactivating spheres work...').ordered
  #      expect(sphere1).to receive(:deactivate!).with(no_args()).ordered
  #      expect(Biosphere::Log).to receive(:info).with('Activating spheres private, project...').ordered
  #      expect(sphere2).to receive(:activate!).with(0).ordered
  #      expect(sphere3).to receive(:activate!).with(1).ordered
  #      expect(Biosphere::Augmentations).to receive(:call).with(spheres: [sphere2, sphere3])
  #      action.call
  #    end
  #  end
  #end

end
