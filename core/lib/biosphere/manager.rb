require 'biosphere/container'
require 'biosphere/log'

module Biosphere
  class Manager < Container

    def self.find(name)
      store[name]
    end

  end
end