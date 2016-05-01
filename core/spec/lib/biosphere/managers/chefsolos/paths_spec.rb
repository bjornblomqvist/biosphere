require 'spec_helper'
require 'biosphere/managers/chefsolos/paths'
require 'biosphere/resources/sphere'

RSpec.describe Biosphere::Managers::Chefsolos::Paths  do

  describe '#solo_json' do
    it 'is the path to the solo.json file' do
      sphere = Biosphere::Resources::Sphere.new('test1')
      path = described_class.new(sphere: sphere).solo_json
      expect(path).to be_instance_of Pathname
      expect(path).to eq Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/solo.json')
    end
  end

  describe '#knife_config' do
    it 'is the path to the knife.rb file' do
      sphere = Biosphere::Resources::Sphere.new('test1')
      path = described_class.new(sphere: sphere).knife_config
      expect(path).to be_instance_of Pathname
      expect(path).to eq Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/knife.rb')
    end
  end

  describe '#checksums' do
    it 'is the path to chef-internal checksums cache directory' do
      sphere = Biosphere::Resources::Sphere.new('test1')
      path = described_class.new(sphere: sphere).checksums
      expect(path).to be_instance_of Pathname
      expect(path).to eq Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/cache/checksums')
    end
  end

  describe '#cache' do
    it 'is the path to chef-internal main cache directory' do
      sphere = Biosphere::Resources::Sphere.new('test1')
      path = described_class.new(sphere: sphere).cache
      expect(path).to be_instance_of Pathname
      expect(path).to eq Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/cache/cache')
    end
  end

  describe '#backups' do
    it 'is the path to chef-internal backups cache directory' do
      sphere = Biosphere::Resources::Sphere.new('test1')
      path = described_class.new(sphere: sphere).backups
      expect(path).to be_instance_of Pathname
      expect(path).to eq Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/cache/backups')
    end
  end

end
