require 'biosphere/action'
require 'biosphere/resources/sphere'

module Biosphere
  module Actions
    # ErrorCodes: 3-19
    class Activate

      attr_reader :sphere_names

      def initialize(args)
        @sphere_names = args
      end

      def perform
        return help if Runtime.help_mode?
        activate
        augment
      end

      private

      def help
        Log.separator
        Log.info "  bio activate SPHERE1 SPHERE2...".bold
        Log.separator
        Log.info "  Activates Spheres by updating the augmentations."
        Log.separator
        Log.info "  Examples:".cyan
        Log.separator
        Log.info "  bio activate                   ".bold + "Reactivate all currently activated Spheres.".cyan
        Log.info "  bio activate myproject         ".bold + "Activate only Sphere myproject.".cyan
        Log.info "  bio activate work myproject    ".bold + "Activate work as primary Sphere and myprojcet as secondary.".cyan
        Log.separator
      end

      def activate
        if spheres_to_activate.empty?
          Log.info "No Spheres to (re-)activate."
          return
        end

        unless spheres_to_deactivate.empty?
          Log.info "Deactivating spheres #{spheres_to_deactivate.map(&:name).join(', ')}..."
          spheres_to_deactivate.each(&:deactivate!)
        end

        Log.info "Activating spheres #{spheres_to_activate.map(&:name).join(', ')}..."
        spheres_to_activate.each_with_index do |sphere, index|
          sphere.activate! index
        end
      end

      def augment
        Augmentations.perform :spheres => spheres_to_activate
      end

      def spheres_to_activate
        @spheres_to_activate ||= begin
          if sphere_names.empty?
            Resources::Sphere.all.select(&:activated?).sort_by(&:activation_order)
          else
            Resources::Sphere.find sphere_names
          end
        end
      end

      def spheres_to_deactivate
        Resources::Sphere.find Resources::Sphere.all.select(&:activated?).map(&:name) - spheres_to_activate.map(&:name)
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Activate
