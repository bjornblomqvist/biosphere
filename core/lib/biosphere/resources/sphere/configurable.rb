require 'biosphere/resources/sphere/config'

module Biosphere
  module Resources
    class Sphere
      module Configurable

        def config_value(key)
          config[key]
        end

        def set_config_value(key, value)
          config[key] = value
        end

        private

        def config
          @config ||= Config.new config_file_path
        end

        def config_file_name
          'sphere.yml'
        end

        def config_file_path
          path.join(config_file_name)
        end

        def ensure_config_file
          config.ensure!
        end

      end
    end
  end
end
