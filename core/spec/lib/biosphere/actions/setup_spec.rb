require 'spec_helper'
require 'biosphere/error'
require 'biosphere/actions/setup'
require 'biosphere/resources/file'

describe Biosphere::Actions::Setup do

  let(:pathname) { mock(:pathname, :exist? => false, :expand_path => true)}
  let(:action) { Biosphere::Actions::Setup.new @args }

  before do
    @args = []
    Pathname.stub(:new).and_return pathname
  end

  context 'no arguments' do
    describe '.perform' do
      it 'show help' do
        action.should_receive(:help)
        action.perform
      end
    end
  end

end
