require 'spec_helper'
require 'biosphere/actions/setup'
require 'biosphere/paths'
require 'tmpdir'

RSpec.describe Biosphere::Actions::Setup do

  describe '.call' do
    context 'no arguments' do
      it 'creates the bash profile file' do
        Pathname.home_path = Dir.mktmpdir
        puts Pathname.home_path.inspect
        expect(Biosphere::Paths.bash_profile.exist?).to be false
        described_class.new([]).call
        expect(Biosphere::Paths.bash_profile.exist?).to be true
        expect(Biosphere::Paths.bash_profile.read).to eq <<-END.undent


          ### BIOSPHERE MANAGED START ###

          # Adding the "bio" executable to your path. Just for your convenience.
          export PATH="/dev/null/biosphere/core/bin:$PATH"

          # Loading Biosphere shell additions (for clean and simple de-/activation of spheres).
          # This line won't change and is safe to be commited to your dotfiles if you wish.
          [[ -s /dev/null/biosphere/augmentations/bash_profile ]] && source /dev/null/biosphere/augmentations/bash_profile

          ### BIOSPHERE MANAGED STOP ###

        END
      end
    end
  end

  describe '.template' do
    context 'context' do
      it 'knows the correct paths' do
        template = described_class.new([]).send(:template, 'my_file')
        expect(template).to eq <<-END.undent
          # Adding the "bio" executable to your path. Just for your convenience.
          export PATH="/dev/null/biosphere/core/bin:$PATH"

          # Loading Biosphere shell additions (for clean and simple de-/activation of spheres).
          # This line won't change and is safe to be commited to your dotfiles if you wish.
          [[ -s /dev/null/biosphere/augmentations/my_file ]] && source /dev/null/biosphere/augmentations/my_file
        END
      end
    end
  end

end
