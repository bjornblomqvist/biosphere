require 'spec_helper'
require 'biosphere/container'

RSpec.describe Biosphere::Container do

  describe '.register' do
    context 'a Class' do
      it 'registers the Class without namespace' do
        klass = Class.new { extend Biosphere::Container }
        klass.register Biosphere::Container
        expect(klass.find(:container)).to eq Biosphere::Container
      end
    end
  end

  describe '.all' do
    context 'no registrations' do
      it 'is an empty Array' do
        klass = Class.new { extend Biosphere::Container }
        expect(klass.all).to eq []
      end
    end

    context 'with a registration' do
      it 'is an Array with the registered object' do
        klass = Class.new { extend Biosphere::Container }
        klass.register Biosphere::Container
        expect(klass.all).to eq [Biosphere::Container]
      end
    end
  end

end
