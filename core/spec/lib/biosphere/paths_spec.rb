require 'spec_helper'
require 'biosphere/paths'

describe Biosphere::Paths do
  let(:paths) { Biosphere::Paths }

  it 'returns the correct path' do
    expect(paths.augmentations).to be_instance_of Pathname
    expect(paths.augmentations.to_s).to eq('/dev/null/biosphere/augmentations')
  end

end
