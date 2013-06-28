module Biosphere
  module Managers
    class Default

      def initialize(options={})
        @sphere = options[:sphere]
        @config = options[:config]
      end

      def perform
        Log.info "Not updating sphere #{sphere.name.bold} because #{self.class.name} does not implement anything useful."
      end

      def to_s
        name
      end

      def description
        name
      end

      def as_json
        { :identifier => name, :description => description, :config => config.as_json }
      end

      def to_json
        as_json.to_json
      end

      private

      def default_env_vars
        { 'GEM_HOME' => Resources::Gem.rubygems_path, 'BIOSPHERE_HOME' => Paths.biosphere_home, 'BIOSPHERE_SPHERE_PATH' => sphere.path, 'BIOSPHERE_SPHERE_AUGMENTATIONS_PATH' => sphere.augmentations_path }
      end

      def name
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