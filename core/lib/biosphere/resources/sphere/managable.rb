module Biosphere
  module Errors
    class InvalidManagerConfiguration < Error
      def code() 3 end
    end
  end
end

module Biosphere
  module Resources
    class Sphere
      module Managable

        def manager
          unless manager = Manager.find(manager_name)
            message = %{The sphere #{name.to_s.inspect} has defined the manager #{manager_name.inspect} in its config file (#{config_file_path}). But that manager could not be found by Biosphere::Manager.}.red
            Log.error message
            raise Errors::InvalidSphereName, message
          end
          manager.new :sphere => self, :config => manager_config
        end

        private

        def manager_config
          if manager_name == 'manual'
            Manager::Config.new
          else
            Manager::Config.new config[:manager][manager_name]
          end
        end

        def manager_name
          return 'manual' unless config[:manager]

          unless config[:manager].is_a?(Hash)
            message = %{You specified a "manager" key in your configuration at #{config_file_path} but that key has to be a Hash.}.red
            Log.error message
            raise Errors::InvalidManagerConfiguration, message
          end

          if config[:manager].keys.size > 1
            message = %{In your configuration at #{config_file_path} you specified multiple managers (#{config[:manager].keys.join(', ')}) but currently biosphere only supports one manager per Spehre}.red
            Log.error message
            raise Errors::InvalidManagerConfiguration, message
          else
            config[:manager].keys.first.to_s
          end
        end

      end
    end
  end
end
