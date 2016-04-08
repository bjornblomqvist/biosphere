require 'biosphere/log'

module Biosphere
  module Container
    extend self

    attr_reader :store

    def register(object)
      object_name = object_to_name(object)
      Log.debug { "Registering #{object_to_name(self)} #{object_name.inspect}..." }
      store[object_name] = object
    end

    def find(name)
      store[name.to_s]
    end

    def all
      store.values.sort_by(&:to_s)
    end

    private

    def store
      @store ||= {}
    end

    def object_to_name(object)
      name = object.name || 'Anonymous Class'
      name.underscore.split('/').last
    end

    # Useful for testing
    def reset!
      @store = nil
    end

  end
end
