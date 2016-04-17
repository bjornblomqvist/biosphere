require 'spec_helper'
require 'biosphere/actions/list'
require 'tmpdir'

RSpec.describe Biosphere::Actions::List do

  describe '#call' do
    it 'does not fail' do
      Biosphere::Paths.biosphere_home = Dir.mktmpdir
      sphere = Biosphere::Resources::Sphere.new('test1').create!
      sphere = Biosphere::Resources::Sphere.new('test2').create!

      instance = described_class.new([])
      instance.call
    end
  end

end
