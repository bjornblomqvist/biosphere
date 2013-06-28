require 'biosphere/action'

module Biosphere
  module Actions
    class Deactivate

      def initialize(args)
        @args = args
      end

      def perform
        return help if Runtime.help_mode?
        deactivate
        augment
      end

      private

      def help
        Log.separator
        Log.info '  bio deactivate'.bold
        Log.separator
        Log.info '  Deactivates all active Spheres by removing all augmentations.'
        Log.separator
      end

      def deactivate
        Log.debug 'Deactivating all Spheres...'
        Resources::Sphere.all.each &:deactivate!
      end

      def augment
        Augmentations.perform
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Deactivate
