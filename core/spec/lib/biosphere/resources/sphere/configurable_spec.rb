require 'spec_helper'
require 'biosphere/resources/sphere/configurable'

class ConfigurableSphereTest
  include Biosphere::Resources::Sphere::Configurable
end

RSpec.describe Biosphere::Resources::Sphere::Configurable do

  let(:config) { double(:config) }
  let(:sphere) { ConfigurableSphereTest.new }

  before do
    @path = Pathname.new('/dev/null')

    allow(sphere).to receive(:path).and_return @path
    allow(Biosphere::Resources::File).to receive(:ensure)
    allow(Biosphere::Resources::File).to receive(:write)
    allow(Biosphere::Resources::File).to receive(:delete)
  end

  describe '#get_config_value' do
    it 'calls the Config backend to retrieve the value' do
      expect(config).to receive(:[]).with('books').and_return(:value)
      expect(sphere).to receive(:config).and_return config
      expect(sphere.config_value('books')).to eq(:value)
    end
  end

  describe '#set_config_value' do
    it 'calls the Config backend to set the value' do
      expect(config).to receive(:[]=).with('books', 'lesmiserables')
      expect(sphere).to receive(:config).and_return config
      sphere.set_config_value('books', 'lesmiserables')
    end
  end

end
