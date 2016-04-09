require 'spec_helper'
require 'biosphere/resources/spheres/config'
require 'tmpdir'

RSpec.describe Biosphere::Resources::Spheres::Config do

  describe '#to_hash' do
    context 'valid yaml content' do
      it 'is the yaml content as Hash' do
        instance = described_class.new('/dev/null')
        allow(instance).to receive(:yaml).and_return <<-END.undent
          alpha:
            two:
              three: 'Three'
              four: 'Four'
          beta: 'Beta'
        END

        expect(instance.to_hash).to eq 'alpha' => { 'two' => { 'three' => 'Three', 'four' => 'Four' } }, 'beta' => 'Beta'
      end
    end
  end

  describe 'create!' do
    context 'normal conditions' do
      it 'creates the file' do
        directory = Dir.mktmpdir
        path = Pathname.new(directory).join('config.yml')
        instance = described_class.new(path)
        expect(path).to_not exist
        instance.create!
        expect(path).to exist
        expect(path.read).to include 'configure how'
      end
    end
  end

  #let(:config) { Biosphere::Resources::Spheres::Config.new('/dev/null') }
  #
  #before do
  #  @path = double(:path, :to_s => '/dev/null')
  #  allow(@path).to receive(:readable?).and_return true
  #  allow(@path).to receive(:writable?).and_return true
  #  allow(@path).to receive(:read).and_return "manager:\n  chefserver:\n    url: 'www.example.com'\n    node_name: bob.biosphere"
  #  allow(config).to receive(:path).and_return @path
  #  allow(Biosphere::Resources::File).to receive(:ensure)
  #  allow(Biosphere::Resources::File).to receive(:write)
  #  allow(Biosphere::Resources::File).to receive(:delete)
  #end

  #describe '#[]' do
  #  it 'is nil if the config file is readable but emtpy' do
  #    allow(@path).to receive(:readable?).and_return false
  #    expect(config['manager']).to be_nil
  #  end
  #
  #  it 'returns a Hash with all configuration data' do
  #    expect(config['manager']).to eq({ "chefserver" => { "url" => "www.example.com", "node_name" => "bob.biosphere" }})
  #  end
  #
  #  it 'returns a leaf' do
  #    expect(config['manager.chefserver.url']).to eq("www.example.com")
  #  end
  #end
  #
  #describe '#[]=' do
  #  it 'saves a new value' do
  #    expect(Biosphere::Resources::File).to receive(:write) do |arg1, arg2|
  #      expect(arg1).to eq(@path)
  #      expect(arg2).to include('brand: :new')
  #    end
  #    config['brand'] = :new
  #    expect(config.to_h).to eq({ "brand" => :new, "manager" => { "chefserver" => { "url" => "www.example.com", "node_name" => "bob.biosphere" }}})
  #  end
  #
  #  it 'merges a subtree from a flat key' do
  #    config['manager.chefserver'] = :new
  #    expect(config.to_h).to eq({ "manager" => { "chefserver" => :new }})
  #  end
  #end

end
