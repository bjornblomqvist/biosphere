require 'spec_helper'
require 'biosphere/augmentations'
require 'biosphere/paths'
require 'biosphere/resources/sphere'
require 'tmpdir'

RSpec.describe Biosphere::Augmentations do

  describe '#call' do
    context 'no ssh augmentations' do
      it 'puts all files in the augmentsitons dir' do
        Biosphere::Paths.augmentations.mkdir
        sphere = Biosphere::Resources::Sphere.new('test')
        sphere.create!
        sphere.activate!

        Biosphere::Paths.augmentations.join('outdated_file').open('w') { |io| io.write nil }
        sphere.augmentations_path.join('shell').open('w')      { |io| io.write 'new shell' }
        sphere.augmentations_path.join('some_file').open('w')  { |io| io.write 'new some file' }

        expect(Biosphere::Paths.augmentations.children.size).to eq 1
        expect(Biosphere::Paths.ssh_config).to_not exist
        described_class.new(sphere: sphere).call
        expect(Biosphere::Paths.augmentations.children.size).to eq 2
        expect(Biosphere::Paths.augmentations.join('shell').read).to eq 'new shell'
        expect(Biosphere::Paths.augmentations.join('some_file').read).to eq 'new some file'
        expect(Biosphere::Paths.ssh_config).to_not exist
      end
    end

    context 'no .ssh directory' do
      it 'puts all relevant files in the new position, even outside the sandbox' do
        Biosphere::Paths.augmentations.mkdir
        sphere = Biosphere::Resources::Sphere.new('test')
        sphere.create!
        sphere.activate!

        Biosphere::Paths.augmentations.join('outdated_file').open('w') { |io| io.write nil }
        sphere.augmentations_path.join('shell').open('w')      { |io| io.write 'new shell' }
        sphere.augmentations_path.join('some_file').open('w')  { |io| io.write 'new some file' }
        sphere.augmentations_path.join('ssh_config').open('w') { |io| io.write 'new ssh config' }

        expect(Biosphere::Paths.augmentations.children.size).to eq 1
        expect(Biosphere::Paths.ssh_config).to_not exist
        described_class.new(sphere: sphere).call
        expect(Biosphere::Paths.augmentations.children.size).to eq 3
        expect(Biosphere::Paths.augmentations.join('shell').read).to eq 'new shell'
        expect(Biosphere::Paths.augmentations.join('some_file').read).to eq 'new some file'
        expect(Biosphere::Paths.augmentations.join('ssh_config').read).to eq 'new ssh config'
        expect(Biosphere::Paths.ssh_config).to exist
      end
    end

    context '.ssh directory and config exist' do
      it 'puts all relevant files in the new position' do
        Biosphere::Paths.augmentations.mkdir
        sphere = Biosphere::Resources::Sphere.new('test')
        sphere.create!
        sphere.activate!

        Biosphere::Paths.augmentations.join('outdated_file').open('w') { |io| io.write nil }
        sphere.augmentations_path.join('shell').open('w')      { |io| io.write 'new shell' }
        sphere.augmentations_path.join('some_file').open('w')  { |io| io.write 'new some file' }
        sphere.augmentations_path.join('ssh_config').open('w') { |io| io.write 'new ssh config' }
        Biosphere::Paths.ssh_config.dirname.mkdir
        Biosphere::Paths.ssh_config.open('w') { |io| io.write 'current ssh config' }

        expect(Biosphere::Paths.augmentations.children.size).to eq 1
        expect(Biosphere::Paths.ssh_config.read).to eq 'current ssh config'
        described_class.new(sphere: sphere).call
        expect(Biosphere::Paths.augmentations.children.size).to eq 3
        expect(Biosphere::Paths.augmentations.join('shell').read).to eq 'new shell'
        expect(Biosphere::Paths.augmentations.join('some_file').read).to eq 'new some file'
        expect(Biosphere::Paths.augmentations.join('ssh_config').read).to eq 'new ssh config'
        expect(Biosphere::Paths.ssh_config.read).to eq <<-END.undent
          current ssh config

          ### BIOSPHERE MANAGED START ###

          new ssh config

          ### BIOSPHERE MANAGED STOP ###

        END
      end
    end
  end

  describe '.implode' do
    context 'context' do
      it 'removes all augmentations' do
        Biosphere::Paths.ssh_config.dirname.mkdir
        Biosphere::Paths.ssh_config.open('w') { |io| io.write 'current ssh config' }
        Biosphere::Paths.augmentations.mkdir
        Biosphere::Paths.augmentations.join('some_file').open('w') { |io| io.write nil }
        Biosphere::Paths.augmentations.join('ssh_config').open('w') { |io| io.write 'new ssh config' }

        expect(Biosphere::Paths.ssh_config.read).to eq 'current ssh config'
        described_class.new.call
        expect(Biosphere::Paths.ssh_config.read).to include 'current ssh config'
        expect(Biosphere::Paths.ssh_config.read).to include 'BIOSPHERE'
        described_class.implode
        expect(Biosphere::Paths.ssh_config.read).to eq "current ssh config\n\n"
      end
    end
  end

end
