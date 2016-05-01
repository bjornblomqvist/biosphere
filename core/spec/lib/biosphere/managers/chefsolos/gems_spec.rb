require 'spec_helper'
require 'biosphere/managers/chefsolos/gems'

RSpec.describe Biosphere::Managers::Chefsolos::Gems do

  describe '#call' do
    context 'no version specified' do
      it 'installs chef zero and then chef' do
        chef_zero = double :chef_zero
        chef = double :chef
        expect(chef_zero).to receive(:call)
        expect(chef).to receive(:call)
        expect(Biosphere::Resources::Gem).to receive(:new).with(name: :chef, version: '12.8.1').and_return chef
        expect(Biosphere::Resources::Gem).to receive(:new).with(name: 'chef-zero', version: '4.5.0').and_return chef_zero

        instance = described_class.new
        instance.call
      end
    end

    context 'custom chef version specified' do
      it 'installs only chef' do
        chef = double :chef
        expect(chef).to receive(:call)
        expect(Biosphere::Resources::Gem).to receive(:new).with(name: :chef, version: '1.2.3').and_return chef

        instance = described_class.new version: '1.2.3'
        instance.call
      end
    end
  end

  describe '#version' do
    context 'no version specified' do
      it 'is the default native chef gem version' do
        instance = described_class.new
        expect(instance.version).to eq '12.8.1'
        expect(instance).to be_native
      end
    end

    context 'specific version specified' do
      it 'is that non-native version' do
        instance = described_class.new version: '42.42.42'
        expect(instance.version).to eq '42.42.42'
        expect(instance).to_not be_native
      end
    end
  end

  describe '#chef_solo_executable' do
    it 'is the path to the chef-solo executable' do
      path = described_class.new.chef_solo_executable
      expected_path = Biosphere::Paths.biosphere_home.join('vendor/gems/2.0.0/gems/chef-12.8.1/bin/chef-solo')

      expect(path).to be_instance_of Pathname
      expect(path).to eq expected_path
    end
  end

end
