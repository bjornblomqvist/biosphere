require 'spec_helper'
require 'biosphere/resources/sphere'
require 'biosphere/errors'
require 'biosphere/managers/manual'
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

  describe '#create!' do
    context 'valid name' do
      it 'creates the sphere directory' do
        sphere = described_class.new('work')
        expect(sphere.path).to_not exist
        sphere.create!
        expect(sphere.path).to exist
      end
    end

    context 'valid name' do
      it 'creates an example configuration' do
        sphere = described_class.new('myproject')
        expect(sphere.path.join('sphere.yml')).to_not exist
        sphere.create!
        expect(sphere.path.join('sphere.yml')).to exist
        expect(sphere.path.join('sphere.yml').read).to include 'configure how'
      end
    end

    context 'directory and config file already exist' do
      it 'does not re-create the sphere yml file' do
        sphere = described_class.new('someproject')
        sphere.path.mkpath
        sphere.path.join('sphere.yml').open('w') { |io| io.write 'some content' }
        sphere.create!
        expect(sphere.path.join('sphere.yml').read).to eq 'some content'
      end
    end
  end

  describe '#activate!' do
    context 'no parameter' do
      it 'activates the sphere' do
        sphere = described_class.new('work')
        sphere.create!
        expect(sphere).to_not be_activated
        sphere.activate!
        expect(sphere).to be_activated
      end
    end
  end

  describe '#deactivate!' do
    context 'no parameter' do
      it 'deactivates the sphere' do
        sphere = described_class.new('work')
        sphere.create!
        sphere.activate!
        expect(sphere).to be_activated
        sphere.deactivate!
        expect(sphere).to_not be_activated
      end
    end
  end

  describe '#manager_name' do
    context 'no manager' do
      it 'is manual' do
        sphere = described_class.new('work')
        sphere.create!
        expect(sphere.send(:manager_name)).to eq 'manual'
      end
    end

    context 'manager defined as string' do
      it 'raises an error' do
        sphere = described_class.new('work')
        sphere.create!
        sphere.send(:config_file_path).open('w') { |io| io.write "manager:  some_string" }
        expect { sphere.send(:manager_name) }.to raise_error Biosphere::Errors::InvalidManagerConfigurationError
      end
    end

    context 'manager defined as Hash with multiple keys' do
      it 'raises an error' do
        sphere = described_class.new('work')
        sphere.create!
        sphere.send(:config_file_path).open('w') { |io| io.write "manager:\n  first: this\n  then: that" }
        expect { sphere.send(:manager_name) }.to raise_error Biosphere::Errors::InvalidManagerConfigurationError
      end
    end
  end

  describe '#manager' do
    context 'no manager' do
      it 'is the manual manager' do
        sphere = described_class.new('work')
        sphere.create!
        expect(sphere.manager).to be_instance_of Biosphere::Managers::Manual
      end
    end

    context 'unknown manager' do
      it 'raises an error' do
        sphere = described_class.new('work')
        sphere.create!
        sphere.send(:config_file_path).open('w') { |io| io.write "manager:\n  boss:\n    some: thing" }
        expect { sphere.manager }.to raise_error Biosphere::Errors::UnknownManagerError
      end
    end
  end

  describe '#cache_path' do
    it 'is the (created) cache path as Pathname instance' do
      sphere = described_class.new('work')
      path = sphere.cache_path
      expect(path).to be_directory
    end
  end

  describe '#update' do
    it 'delegates to the manager' do
      sphere = described_class.new('work')
      expect(sphere.manager).to receive(:call).with(no_args())
      sphere.create!
      sphere.update
    end
  end

  describe '#config' do
    context 'invalid YAML' do
      it 'raises an error' do
        sphere = described_class.new('work')
        sphere.create!
        sphere.send(:config_file_path).open('w') { |io| io.write 'totally / invalid : yaml :' }
        expect { sphere.manager }.to raise_error Biosphere::Errors::InvalidConfigYaml
      end
    end

    context 'root element is an Array' do
      it 'raises an error' do
        sphere = described_class.new('work')
        sphere.create!
        sphere.send(:config_file_path).open('w') { |io| io.write "- one\n-two" }
        expect { sphere.manager }.to raise_error Biosphere::Errors::InvalidConfigYaml
      end
    end
  end

end
