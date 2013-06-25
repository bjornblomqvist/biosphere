require 'biosphere/extensions/string'
require 'biosphere/log'
require 'singleton'

module Biosphere
  module Container
    extend self

    attr_reader :store

    def register(object)
      object_name = object_to_name(object)
      Log.debug "Registering #{self} #{object_name.inspect}..."
      store[object_name] = object
    end

    def find(name)
      store[name.to_s]
    end

    def object_to_name(object)
      object.name.underscore.split('/').last
    end

    #def all
    #  store.values
    #end

    private

    #def name
    #  self.to_s.split('::').last
    #end

    def store
      @store ||= {}
    end

    # Useful for testing
    def unregister(object)
      store.delete object_to_name(object)
    end

    # Useful for testing
    def reset!
      @store = nil
    end

  end
end
