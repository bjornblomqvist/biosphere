require 'spec_helper'
require 'biosphere/resources/sphere/configurable'

class ConfigurableSphereTest
  include Biosphere::Resources::Sphere::Configurable
end

describe Biosphere::Resources::Sphere::Configurable do

  let(:config) { mock(:config) }
  let(:sphere) { ConfigurableSphereTest.new }

  before do
    @path = Pathname.new('/dev/null')

    sphere.stub(:path).and_return @path
    Biosphere::Resources::File.stub(:ensure)
    Biosphere::Resources::File.stub(:write)
    Biosphere::Resources::File.stub(:delete)
  end

  describe '#get_config_value' do
    it 'calls the Config backend to retrieve the value' do
      config.should_receive(:[]).with('books').and_return(:value)
      sphere.should_receive(:config).and_return config
      sphere.config_value('books').should == :value
    end
  end

  describe '#set_config_value' do
    it 'calls the Config backend to set the value' do
      config.should_receive(:[]=).with('books', 'lesmiserables')
      sphere.should_receive(:config).and_return config
      sphere.set_config_value('books', 'lesmiserables')
    end
  end

end