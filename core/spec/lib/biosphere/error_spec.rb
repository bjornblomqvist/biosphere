require 'spec_helper'
require 'biosphere'

class ErrorSpecErrorOne < Biosphere::Errors::Error
  def code() 777 end
end

class ErrorSpecErrorTwo < Biosphere::Errors::Error
  def code() 999 end
end

class ErrorSpecErrorThree < Biosphere::Errors::Error
  def code() 777 end
end

describe Biosphere::Errors::Error do

  context 'no conflicting error code definitions' do
    describe '.valid?' do
      it 'is true' do
        Biosphere::Errors.should be_valid
      end
    end

    describe '.validate!' do
      it 'raises no exception' do
        Biosphere::Errors.validate!
      end
    end
  end

  context 'with conflicting code definitions' do
    before do
      Biosphere::Errors.stub!(:names).and_return %w{ ErrorSpecErrorOne ErrorSpecErrorTwo ErrorSpecErrorThree }
    end

    describe '.valid?' do
      it 'is false' do
        Biosphere::Errors.should_not be_valid
      end
    end

    describe '.validate!' do
      it 'raises an error' do
        expect { Biosphere::Errors.validate! }.to raise_error(Biosphere::Errors::ErrorCodesAssignmentError)
      end
    end
  end

end
