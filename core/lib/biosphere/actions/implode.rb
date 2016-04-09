require 'biosphere/action'

module Biosphere
  module Actions
    class Implode

      def initialize(args)
        @args = args
      end

      def perform
        return help if Runtime.help_mode?

        Log.separator
        deactivate_all
        implode
        implode_bash_profile
        Log.info "  All Spheres have been deactivated and all augmentations have been removed entirely.".green
        Log.separator
      end

      private

      def help
        Log.separator
        Log.info "  bio implode".bold
        Log.separator
        Log.info "  Removes all possible traces of Biosphere from your System, except the directory #{Paths.biosphere_home.unexpand_path.to_s.bold}"
        Log.separator
      end

      def implode
        # Augmentations.implode
      end

      def deactivate_all
        Action.perform %w{ deactivate }
      end

      def implode_bash_profile
        # TODO
      end

    end
  end
end

Biosphere::Actions.register Biosphere::Actions::Implode
