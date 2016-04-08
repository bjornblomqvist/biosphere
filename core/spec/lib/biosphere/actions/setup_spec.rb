require 'spec_helper'
require 'biosphere/errors'
require 'biosphere/actions/setup'
require 'biosphere/resources/file'

describe Biosphere::Actions::Setup do

  let(:pathname) { double(:pathname, :exist? => false, :expand_path => true)}
  let(:action) { Biosphere::Actions::Setup.new @args }

  before do
    @args = []
    allow(Pathname).to receive(:new).and_return pathname
  end

  context 'no arguments' do
    describe '.perform' do
      it 'show help' do
        expect(action).to receive(:help)
        action.perform
      end
    end
  end

end
