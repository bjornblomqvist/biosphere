require 'biosphere/container'
require 'biosphere/extensions/ostruct'
require 'biosphere/log'

module Biosphere
  module Manager
    extend Container

    Config = Class.new(OpenStruct)

  end
end
