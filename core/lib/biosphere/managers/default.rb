module Biosphere
  module Managers
    class Default

      def initialize(options={})
        @sphere = options[:sphere]
        @config = options[:config]
      end

      def call
        Log.info { "Not updating sphere #{sphere.name.bold} because #{self.class.name} does not implement anything useful." }
      end

      def to_s
        identifier
      end

      # Implement this in a subclass.
      def name
        ''
      end

      # Implement this in a subclass.
      def description
        ''
      end

      private

      def default_env_vars
        {
          'GEM_HOME'                            => Resources::Gem.rubygems_path,
          'BIOSPHERE_HOME'                      => Paths.biosphere_home,
          'BIOSPHERE_SPHERE_NAME'               => sphere.name,
          'BIOSPHERE_SPHERE_PATH'               => sphere.path,
          'BIOSPHERE_SPHERE_AUGMENTATIONS_PATH' => sphere.augmentations_path
        }
      end

      def identifier
        self.class.name.split('::').last.downcase
      end

      def sphere
        @sphere
      end

      def config
        @config
      end

    end
  end
end
