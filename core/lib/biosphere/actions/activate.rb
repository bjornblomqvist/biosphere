require 'biosphere/action'

module Biosphere
  module Actions
    class Activate

      def perform
        Resources::Sphere.all.each do |sphere|
          Log.info sphere.name
        end
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Activate