require 'spec_helper'
require 'biosphere/paths'

describe Biosphere::Paths do
  let(:paths) { Biosphere::Paths }

  it 'returns the correct path' do
    paths.augmentations.should be_instance_of Pathname
    paths.augmentations.to_s.should == '/dev/null/biosphere/augmentations'
  end

end
