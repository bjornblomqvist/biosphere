require 'spec_helper'
require 'biosphere/resources/sphere/config'

__END__

describe Biosphere::Resources::Sphere::Config do

  let(:config) { Biosphere::Resources::Sphere::Config.new('/dev/null') }

  before do
    @path = mock(:path, :to_s => '/dev/null')
    @path.stub(:readable?).and_return true
    @path.stub(:writable?).and_return true
    @path.stub(:read).and_return "manager:\n  chefserver:\n    url: 'www.example.com'\n    node_name: bob.biosphere"
    config.stub(:path).and_return @path
    Biosphere::Resources::File.stub(:ensure)
    Biosphere::Resources::File.stub(:write)
    Biosphere::Resources::File.stub(:delete)
  end

  describe '#[]' do
    it 'is nil if the config file is readable but emtpy' do
      @path.stub(:readable?).and_return false
      config['manager'].should be_nil
    end

    it 'returns a Hash with all configuration data' do
      config['manager'].should == { "chefserver" => { "url" => "www.example.com", "node_name" => "bob.biosphere" }}
    end

    it 'returns a leaf' do
      config['manager.chefserver.url'].should == "www.example.com"
    end
  end

  describe '#[]=' do
    it 'saves a new value' do
      Biosphere::Resources::File.should_receive(:write) do |arg1, arg2|
        arg1.should == @path
        arg2.should include('brand: :new')
      end
      config['brand'] = :new
      config.to_h.should == { "brand" => :new, "manager" => { "chefserver" => { "url" => "www.example.com", "node_name" => "bob.biosphere" }}}
    end

    it 'merges a subtree from a flat key' do
      config['manager.chefserver'] = :new
      config.to_h.should == { "manager" => { "chefserver" => :new }}
    end
  end

end
