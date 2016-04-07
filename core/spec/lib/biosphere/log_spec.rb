require 'spec_helper'

RSpec.describe Biosphere::Log do

  describe '.debug' do
    it 'does something' do
      described_class.debug { 'Wow' }
    end
  end

end
