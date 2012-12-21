require 'biosphere/container'
require 'biosphere/extensions/ostruct'
require 'biosphere/log'

module Biosphere
  class Manager < Container

    Config = Class.new(OpenStruct)

  end
end