require 'spec_helper'
require 'biosphere/extensions/hash'

RSpec.describe Biosphere::Extensions::HashExtensions do

  let(:hash) { { 'one' => :two, 'three' => { 'four' => { 'five' => :six } } } }

end
