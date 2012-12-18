require 'biosphere/action'

module Biosphere
  module Actions
    # ErrorCodes: 10-19
    class Activate

      def perform(args)
        return help if Runtime.help_mode?
        @sphere_names = args
        activate
        augment
      end

      private

      def activate
        if relevant_spheres.empty?
          Log.info "Nothing to activate or reactivate."
        else
          Log.info "Activating Spheres #{relevant_spheres.map(&:name).join(', ')}"
          other_spheres.each do |sphere|
            sphere.deactivate!
          end
          relevant_spheres.each_with_index do |sphere, index|
            sphere.activate! index
          end
        end
      end

      def augment
        augmentator = Augmentator.new :spheres => relevant_spheres
        augmentator.perform
      end

      def relevant_spheres
        @relevant_spheres ||= begin
          if @sphere_names.empty?
            Resources::Sphere.all.select(&:activated?).sort_by(&:activation_order)
          else
            @sphere_names.map do |name|
              Resources::Sphere.find(name)
            end.compact
          end
        end
      end

      def other_spheres
        Resources::Sphere.all - relevant_spheres
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Activate