module Biosphere
  module Resources
    module Spheres
      class Name

        def initialize(name)
          @name = name
        end

        def call
          return unless valid?
          name.to_s
        end

        def valid?
          name.to_s.match(/^[a-z][a-z0-9_]+[^_]$/) && !name.to_s.match(/__/)
        end

        private

        attr_reader :name

      end
    end
  end
end
