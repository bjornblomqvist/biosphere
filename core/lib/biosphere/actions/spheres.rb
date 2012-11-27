require 'biosphere/action'
require 'biosphere/sphere'

module Biosphere
  module Actions
    class Spheres

      def perform
        Sphere.all.each do |sphere|
          Log.info sphere.name
        end
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Spheres.new