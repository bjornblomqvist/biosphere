require 'spec_helper'
require 'biosphere/actions/activate'

RSpec.describe Biosphere::Actions::Activate do

  let(:sphere1) { double(:sphere1, :name => 'work',    :activated? => true,  :activation_order => 1) }
  let(:sphere2) { double(:sphere2, :name => 'private', :activated? => true,  :activation_order => 0) }
  let(:sphere3) { double(:sphere3, :name => 'project', :activated? => false, :activation_order => 2) }
  let(:spheres) { [sphere1, sphere2, sphere3] }

  let(:action) { Biosphere::Actions::Activate.new @args }

  before do
    @args = []
    allow(Biosphere::Resources::Sphere).to receive(:all).and_return spheres
  end

  context 'no arguments' do
    describe '.perform' do
      it 'activates all spheres' do
        expect(Biosphere::Log).to receive(:info).with('Activating spheres private, work...')
        expect(sphere2).to receive(:activate!).with(0).ordered
        expect(sphere1).to receive(:activate!).with(1).ordered
        expect(Biosphere::Augmentations).to receive(:perform).with(:spheres => [sphere2, sphere1])
        action.perform
      end
    end
  end

  context 'with arguments' do
    before do
      @args = %w{ private project }
    end

    describe '.perform' do
      it 'activates the spheres and first deactivates all unused' do
        expect(Biosphere::Log).to receive(:info).with('Deactivating spheres work...').ordered
        expect(sphere1).to receive(:deactivate!).with(no_args()).ordered
        expect(Biosphere::Log).to receive(:info).with('Activating spheres private, project...').ordered
        expect(sphere2).to receive(:activate!).with(0).ordered
        expect(sphere3).to receive(:activate!).with(1).ordered
        expect(Biosphere::Augmentations).to receive(:perform).with(:spheres => [sphere2, sphere3])
        action.perform
      end
    end
  end

end
