require 'spec_helper'
require 'biosphere/actions/version'

describe Biosphere::Actions::Version do

  let(:args)   { %w{ } }
  let(:action) { Biosphere::Actions::Version.new args }

  describe '.perform' do
    it 'reveals the version' do
      #action.perform
    end
  end

end