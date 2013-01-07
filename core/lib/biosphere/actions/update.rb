require 'biosphere/action'
require 'biosphere/resources/sphere'
require 'biosphere/augmentations'

module Biosphere
  module Actions
    # ErrorCodes: 40-49
    class Update

      def perform(args=[])
        return help if Runtime.help_mode?
        @sphere_names = args
        update
      end

      private

      def help
        'Coming soon ...'
      end

      def relevant_spheres
        if @sphere_names.empty?
          Resources::Sphere.all
        else
          @sphere_names.map do |name|
            Resources::Sphere.find(name)
          end.compact
        end
      end

      def update
        Log.separator
        relevant_spheres.each do |sphere|
          result = sphere.update
          if result
            if result.success?
              Log.info "Successfully updated Sphere #{sphere.name.bold}"
              Log.separator
            else
              Log.info "There were problems updating #{sphere.name.bold}"
              Log.separator
            end
          else
            # Sphere is handled manually
          end
        end
        Log.separator
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Update