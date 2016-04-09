require 'spec_helper'
require 'biosphere/resources/sphere'
require 'biosphere/errors'
require 'tmpdir'

RSpec.describe Biosphere::Resources::Sphere do

  describe 'initialize' do
    context 'invalid name' do
      it 'raises an error' do
        expect { described_class.new('1-invalid') }.to raise_error Biosphere::Errors::InvalidSphereName
      end
    end

    context 'valid name' do
      it 'assigns the name' do
        sphere = described_class.new('valid')
        expect(sphere.name).to eq 'valid'
      end
    end
  end

  describe '#activate!' do
    context 'no parameter' do
      it 'activates the sphere' do
        Biosphere::Paths.biosphere_home = Dir.mktmpdir
        sphere = described_class.new('work')
        sphere.create!
        expect(sphere).to_not be_activated
        sphere.activate!
        expect(sphere).to be_activated
      end
    end
  end

end
