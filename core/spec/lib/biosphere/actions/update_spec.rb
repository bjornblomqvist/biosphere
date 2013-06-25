require 'spec_helper'
require 'biosphere/action'
require 'biosphere/actions/update'

describe Biosphere::Actions::Update do

  let(:sphere1) { mock(:sphere1, :name => 'work') }
  let(:sphere2) { mock(:sphere2, :name => 'private') }
  let(:sphere3) { mock(:sphere3, :name => 'project') }
  let(:spheres) { [sphere1, sphere2, sphere3] }

  let(:action) { Biosphere::Actions::Update.new @args }

  before do
    @args = []
  end

  context 'no arguments' do
    describe '.perform' do
      it 'updates all spheres and triggers a global reactivation' do
        Biosphere::Resources::Sphere.should_receive(:all).with(no_args()).and_return spheres
        sphere1.should_receive(:update).with(no_args())
        sphere2.should_receive(:update).with(no_args())
        sphere3.should_receive(:update).with(no_args())
        Biosphere::Action.should_receive(:perform).with(%w{ activate })
        action.perform
      end
    end
  end

  context 'with arguments' do
    before do
      @args = %w{ project work }
    end

    describe '.perform' do
      it 'updates the specified spheres and triggers a global reactivation' do
        Biosphere::Resources::Sphere.should_receive(:find).with('work').and_return sphere1
        Biosphere::Resources::Sphere.should_receive(:find).with('project').and_return sphere3
        sphere1.should_receive(:update).with(no_args())
        sphere3.should_receive(:update).with(no_args())
        Biosphere::Action.should_receive(:perform).with(%w{ activate })
        action.perform
      end
    end
  end

end
