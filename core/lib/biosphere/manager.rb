module Biosphere
  module Manager

    def initialize(sphere: nil, config: nil)
      @sphere = sphere
      @config = config
    end

    def call
      Log.info { "Not updating sphere #{sphere.name.bold} because #{self.class.name} does not implement anything useful in its `#call` method." }
    end

    def name
      'This is the human-readable manager name, implement it in a subclass.'
    end

    def description
      'This is the manager description, implement it in a subclass.'
    end

    def to_s
      identifier
    end

    private

    attr_reader :sphere, :config

    def identifier
      self.class.name.split('::').last.downcase
    end

    def env_vars
      default_env_vars.merge custom_env_vars
    end

    def custom_env_vars
      return {} unless config.env_vars.is_a?(Hash)

      result = {}
      config.env_vars.each do |env_var, value|
        result["BIOSPHERE_ENV_#{env_var.upcase}".to_sym] = value
      end
      result
    end

    def default_env_vars
      {
        GEM_HOME:                            Paths.vendor_gems,
        BIOSPHERE_HOME:                      Paths.biosphere_home,
        BIOSPHERE_SPHERE_NAME:               sphere.name,
        BIOSPHERE_SPHERE_PATH:               sphere.path,
        BIOSPHERE_SPHERE_AUGMENTATIONS_PATH: sphere.augmentations_path
      }
    end

  end
end
