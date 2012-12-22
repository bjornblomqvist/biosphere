require 'biosphere/action'

module Biosphere
  module Actions
    # ErrorCodes: 66-70
    class Implode

      def perform(args=[])
        return help if Runtime.help_mode?
        deactivate_all
        implode
        implode_bash_profile
        #Log.separator
        #Log.info "  All Spheres have been deactivated and all augmentations have been removed entirely.".green
        #Log.separator
      end

      private

      def help
        Log.info "Coming soon..."
      end

      def implode
        Augmentations.implode
      end

      def deactivate_all
        Action.perform %w{ deactivate}
      end

      def implode_bash_profile
        Action.perform %w{ config --implode-bash-profile }
        Action.perform %w{ config --implode-zshenv }
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Implode