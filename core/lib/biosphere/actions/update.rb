require 'biosphere/action'
require 'biosphere/resources/sphere'

module Biosphere
  module Actions
    class Update

      def perform
        Resources::Sphere.all.each do |sphere|
          sphere.update
        end
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Update