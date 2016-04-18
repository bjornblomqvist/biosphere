require 'spec_helper'
require 'biosphere/actions/list'
require 'biosphere/managers/manual'
require 'tmpdir'

RSpec.describe Biosphere::Actions::List do

  describe '#call' do
    context 'there are spheres' do
      it 'does not fail' do
        Biosphere::Paths.biosphere_home = Dir.mktmpdir
        sphere = Biosphere::Resources::Sphere.new('test1').create!
        sphere = Biosphere::Resources::Sphere.new('test2').create!

        instance = described_class.new
        instance.call
      end
    end

    context 'help' do
      it 'shows the help' do
        allow(Biosphere::Runtime).to receive(:help_mode?).and_return true
        instance = described_class.new
        instance.call
      end
    end
  end

end
