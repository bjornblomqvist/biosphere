require 'spec_helper'
require 'biosphere/errors'

RSpec.describe Biosphere::Errors::Error do

  describe '.code' do
    it 'is supposed to be implemented in subclasses' do
      expect { described_class.new.code }.to raise_error NotImplementedError
    end
  end

  context 'exit codes' do
    it 'has no duplicate codes' do
      error_classes = ObjectSpace.each_object(Class).select { |klass| klass < described_class }
      error_codes = error_classes.map(&:new).map(&:code)
      expect(error_codes.uniq).to eq error_codes
    end
  end

end
