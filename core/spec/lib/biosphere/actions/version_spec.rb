require 'spec_helper'
require 'biosphere/actions/version'

RSpec.describe Biosphere::Actions::Version do

  let(:major)   { 0 }
  let(:minor)   { 9 }
  let(:tiny)    { 0 }

  let(:action) { Biosphere::Actions::Version.new @args }

  before do
    @args = []
  end

  describe '.call' do
    it 'reveals the full version string' do
      expect(Biosphere::Log).to receive(:info) do |*args, &block|
        expect(args).to be_empty
        expect(block.call).to eq "Biosphere version #{Biosphere::VERSION}"
      end

      action.call
    end
  end

end
