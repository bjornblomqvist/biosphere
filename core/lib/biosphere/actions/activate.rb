require 'biosphere/action'

module Biosphere
  module Actions
    # ErrorCodes: 3-19
    class Activate

      def perform(args=[])
        return help if Runtime.help_mode?
        @sphere_names = args
        activate
        augment
      end

      private

      def help
        Log.info "Coming soon..."
      end

      def activate
        if spheres_to_activate.empty?
          Log.info "No Spheres to (re-)activate."
        else
          unless spheres_to_deactivate.empty?
            Log.info "Deactivating Spheres #{spheres_to_deactivate.map(&:name).join(', ')}..."
            spheres_to_deactivate.each(&:deactivate!)
          end
          Log.info "Activating Spheres #{spheres_to_activate.map(&:name).join(', ')}..."
          spheres_to_activate.each_with_index do |sphere, index|
            sphere.activate! index
          end
        end
      end

      def augment
        Augmentations.perform :spheres => spheres_to_activate
      end

      def spheres_to_activate
        @spheres_to_activate ||= begin
          if @sphere_names.empty?
            Resources::Sphere.all.select(&:activated?).sort_by(&:activation_order)
          else
            Resources::Sphere.find @sphere_names
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