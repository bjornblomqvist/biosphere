require 'spec_helper'
require 'biosphere/actions/activate'

describe Biosphere::Actions::Activate do

  let(:sphere1) { mock(:sphere1, :name => 'work',    :activated? => true,  :activation_order => 1) }
  let(:sphere2) { mock(:sphere2, :name => 'private', :activated? => true,  :activation_order => 0) }
  let(:sphere3) { mock(:sphere3, :name => 'project', :activated? => false, :activation_order => 2) }
  let(:spheres) { [sphere1, sphere2, sphere3] }

  let(:action) { Biosphere::Actions::Activate.new @args }

  before do
    @args = []
    Biosphere::Resources::Sphere.stub(:all).and_return spheres
  end

  context 'no arguments' do
    describe '.perform' do
      it 'activates all spheres' do
        Biosphere::Log.should_receive(:info).with('Activating spheres private, work...')
        sphere2.should_receive(:activate!).with(0).ordered
        sphere1.should_receive(:activate!).with(1).ordered
        Biosphere::Augmentations.should_receive(:perform).with(:spheres => [sphere2, sphere1])
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
        Biosphere::Log.should_receive(:info).with('Deactivating spheres work...').ordered
        sphere1.should_receive(:deactivate!).with(no_args()).ordered
        Biosphere::Log.should_receive(:info).with('Activating spheres private, project...').ordered
        sphere2.should_receive(:activate!).with(0).ordered
        sphere3.should_receive(:activate!).with(1).ordered
        Biosphere::Augmentations.should_receive(:perform).with(:spheres => [sphere2, sphere3])
        action.perform
      end
    end
  end

end
