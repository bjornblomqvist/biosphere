require 'biosphere/action'
require 'biosphere/resources/sphere'

module Biosphere
  module Actions
    class Spheres

      def perform
        Resources::Sphere.all.each do |sphere|
          Log.info sphere.name
        end
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Spheres