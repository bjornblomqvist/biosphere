require 'spec_helper'
require 'biosphere/container'

describe Biosphere::Container do
  let(:container) { Biosphere::Container }
  let(:object) { mock(:object, :name => 'Im::Some::Bird') }

  after do
    container.send(:reset!)
  end

  describe '.find' do
    it 'finds a registered object' do
      container.register object
      container.find('bird').should be object
    end

    it 'is nil if the object was never registered' do
      container.find(:bird).should be_nil
    end
  end

end
