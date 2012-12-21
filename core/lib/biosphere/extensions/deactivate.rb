require 'biosphere/action'

module Biosphere
  module Actions
    # ErrorCodes: 3-19
    class Deactivate

      def perform(args=[])
        return help if Runtime.help_mode?
        deactivate_all
        augment
      end

      private

      def help
        Log.info "Coming soon..."
      end

      def deactivate_all
        Log.info "Deactivating all Spheres..."
        Resources::Sphere.all do |sphere|
          sphere.deactivate! index
        end
      end

      def augment
        Augmentator.new.perform
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Deactivate