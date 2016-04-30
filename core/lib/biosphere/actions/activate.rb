require 'biosphere/actions'
require 'biosphere/resources/sphere'
require 'biosphere/spheres'
require 'biosphere/augmentations'

module Biosphere
  module Actions
    class Activate

      def initialize(args = [])
        @args = args
      end

      def call
        return help if Runtime.help_mode?

        activate
        augment
      end

      private

      def help
        Log.separator
        Log.info { "  bio activate SPHERE".bold }
        Log.separator
        Log.info { "  Activates a Sphere by updating its augmentations." }
        Log.separator
        Log.info { "  Examples:".cyan }
        Log.separator
        Log.info { "  bio activate             ".bold + "Reactivate the currently activated Sphere.".cyan }
        Log.info { "  bio activate myproject   ".bold + "Activate the Sphere myproject.".cyan }
        Log.separator
      end

      def activate
        unless sphere_to_activate
          Log.info { "  No Sphere to activate.".yellow }
          return
        end

        unless spheres_to_deactivate.empty?
          Log.info { "  Deactivating Spheres #{spheres_to_deactivate.map(&:name).join(', ').bold}".green + ".".green }
          spheres_to_deactivate.each(&:deactivate!)
        end

        if sphere_to_activate
          Log.info { "  Activating Sphere #{sphere_to_activate.name.bold}".green + ".".green }
          sphere_to_activate.activate!
        end
      end

      def augment
        return unless sphere_to_activate
        Augmentations.new(sphere: sphere_to_activate).call
      end

      def sphere_name
        @args.first
      end

      def sphere_to_activate
        if sphere_name
          Spheres.find sphere_name
        else
          # Re-activation
          Spheres.activated.first
        end
      end

      def spheres_to_deactivate
        Spheres.activated.reject { |sphere| sphere == sphere_to_activate }
      end

    end
  end
end

Biosphere::Actions.register Biosphere::Actions::Activate
