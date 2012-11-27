require 'biosphere/action'

module Biosphere
  module Actions
    class Update

      def perform
        Sphere.all.each do |sphere|
          sphere.update
        end
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Update