require 'spec_helper'
require 'biosphere/actions/setup'
require 'biosphere/paths'
require 'tmpdir'

RSpec.describe Biosphere::Actions::Setup do

  describe '.call' do
    context 'no arguments' do
      it 'creates the bash profile file' do
        Biosphere::Paths.biosphere_home = '/dev/null/biosphere'
        Pathname.home_path = Dir.mktmpdir
        expect(Biosphere::Paths.bash_profile.exist?).to be false
        described_class.new([]).call
        expect(Biosphere::Paths.bash_profile.exist?).to be true
        expect(Biosphere::Paths.bash_profile.read).to eq <<-END.undent


          ### BIOSPHERE MANAGED START ###

          # Adding the "bio" executable to your path. Just for your convenience.
          export PATH="/dev/null/biosphere/core/bin:$PATH"

          # Loading Biosphere shell additions (for clean and simple de-/activation of spheres).
          # These lines won't change and are safe to be commited to your dotfiles if you wish.
          [[ -s /dev/null/biosphere/augmentations/shell ]] && source /dev/null/biosphere/augmentations/shell

          ### BIOSPHERE MANAGED STOP ###

        END
      end
    end
  end

end
