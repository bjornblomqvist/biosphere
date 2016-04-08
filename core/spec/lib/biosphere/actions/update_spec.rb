require 'spec_helper'
require 'biosphere/actions/update'

RSpec.describe Biosphere::Actions::Update do

  let(:sphere1) { double(:sphere1, :name => 'work') }
  let(:sphere2) { double(:sphere2, :name => 'private') }
  let(:sphere3) { double(:sphere3, :name => 'project') }
  let(:spheres) { [sphere1, sphere2, sphere3] }

  let(:action) { Biosphere::Actions::Update.new @args }

  before do
    @args = []
  end

  context 'no arguments' do
    describe '.perform' do
      it 'updates all spheres and triggers a global reactivation' do
        expect(Biosphere::Resources::Sphere).to receive(:all).with(no_args()).and_return spheres
        expect(sphere1).to receive(:update).with(no_args())
        expect(sphere2).to receive(:update).with(no_args())
        expect(sphere3).to receive(:update).with(no_args())
        expect(Biosphere::Action).to receive(:perform).with(%w{ activate })
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
        expect(Biosphere::Resources::Sphere).to receive(:find).with('work').and_return sphere1
        expect(Biosphere::Resources::Sphere).to receive(:find).with('project').and_return sphere3
        expect(sphere1).to receive(:update).with(no_args())
        expect(sphere3).to receive(:update).with(no_args())
        expect(Biosphere::Action).to receive(:perform).with(%w{ activate })
        action.perform
      end
    end
  end

end
