require 'biosphere/extensions/string'
require 'biosphere/log'
require 'singleton'

module Biosphere
  class Container
    include ::Singleton

    attr_reader :store

    def initialize
      @store = {}
    end

    def self.register(object)
      object_name = object.name.underscore.split('/').last
      Log.debug "Registering #{name} #{object_name.inspect}..."
      instance.store[object_name] = object
    end

    def self.all
      store.values
    end

    private

    def self.name
      self.to_s.split('::').last
    end

    # Internal: Convenience wrapper
    def self.store
      instance.store
    end

  end
end