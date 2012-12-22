require 'biosphere/action'

module Biosphere
  module Actions
    # ErrorCodes: 71-79
    class Deactivate

      def perform(args=[])
        return help if Runtime.help_mode?
        deactivate
        augment
      end

      private

      def help
        Log.info "Coming soon..."
      end

      def deactivate
        Log.debug "Deactivating all Spheres..."
        Resources::Sphere.all.each(&:deactivate!)
      end

      def augment
        Augmentations.perform
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Deactivate