require 'spec_helper'
require 'biosphere/spheres'

RSpec.describe Biosphere::Spheres do

  describe '.find' do
    context 'sphere does not exist' do
      it 'is nil' do
        expect(described_class.find('not you')).to be_nil
      end
    end

  end
end
