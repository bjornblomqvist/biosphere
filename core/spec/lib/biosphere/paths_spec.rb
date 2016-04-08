require 'spec_helper'
require 'biosphere/paths'

RSpec.describe Biosphere::Paths do

  describe '.biosphere_home' do
    context 'the path is unknown' do
      it 'raises an error' do
        described_class.biosphere_home = nil
        expect { described_class.biosphere_home }.to raise_error Biosphere::Errors::BiosphereHomeNotSetError
      end
    end

    context 'the path was set from the outside' do
      it 'is a Pathname instance' do
        expect(described_class.biosphere_home).to be_instance_of Pathname
        expect(described_class.biosphere_home.to_s).to eq('/dev/null/biosphere')
      end
    end
  end

  describe '.augmentations' do
    it 'is a Pathname instance' do
      expect(described_class.augmentations).to be_instance_of Pathname
      expect(described_class.augmentations.to_s).to eq('/dev/null/biosphere/augmentations')
    end
  end

  describe '.shell_augmentation' do
    it 'is a Pathname instance' do
      expect(described_class.shell_augmentation).to be_instance_of Pathname
      expect(described_class.shell_augmentation.to_s).to eq('/dev/null/biosphere/augmentations/shell')
    end
  end

  describe '.ssh_config_augmentation' do
    it 'is a Pathname instance' do
      expect(described_class.ssh_config_augmentation).to be_instance_of Pathname
      expect(described_class.ssh_config_augmentation.to_s).to eq('/dev/null/biosphere/augmentations/ssh_config')
    end
  end

  describe '.spheres' do
    it 'is a Pathname instance' do
      expect(described_class.spheres).to be_instance_of Pathname
      expect(described_class.spheres.to_s).to eq('/dev/null/biosphere/spheres')
    end
  end

  describe '.core_bin' do
    it 'is a Pathname instance' do
      expect(described_class.core_bin).to be_instance_of Pathname
      expect(described_class.core_bin.to_s).to eq('/dev/null/biosphere/core/bin')
    end
  end

  describe '.vendor_gems' do
    it 'is a Pathname instance' do
      expect(described_class.vendor_gems).to be_instance_of Pathname
      expect(described_class.vendor_gems.to_s).to eq('/dev/null/biosphere/vendor/gems/2.0.0')
    end
  end

  describe '.bash_profile' do
    it 'is a Pathname instance' do
      expect(described_class.bash_profile).to be_instance_of Pathname
      expect(described_class.bash_profile.to_s).to eq('/dev/null/home/.bash_profile')
    end
  end

  describe '.zshenv' do
    it 'is a Pathname instance' do
      expect(described_class.zshenv).to be_instance_of Pathname
      expect(described_class.zshenv.to_s).to eq('/dev/null/home/.zshenv')
    end
  end

  describe '.ruby_executable' do
    it 'is a Pathname instance' do
      expect(described_class.ruby_executable).to be_instance_of Pathname
      expect(described_class.ruby_executable.to_s).to eq('/usr/bin/ruby')
    end
  end

  describe '.gem_executable' do
    it 'is a Pathname instance' do
      expect(described_class.gem_executable).to be_instance_of Pathname
      expect(described_class.gem_executable.to_s).to eq('/usr/bin/gem')
    end
  end

end
