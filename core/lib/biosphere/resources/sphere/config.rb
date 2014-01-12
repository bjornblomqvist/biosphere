require 'biosphere/error'
require 'biosphere/log'
require 'biosphere/extensions/hash'
require 'biosphere/resources/file'

module Biosphere
  module Errors
    class InvalidConfigYaml < Error
      def code() 36 end
    end

    class ConfigFileNotWritable < Error
      def code() 37 end
    end
  end
end

module Biosphere
  module Resources
    class Sphere
      class Config
        attr_reader :path

        def initialize(path)
          @path = Pathname.new(path)
        end

        def [](key)
          if flat_key?(key)
            to_h.flatten_keys[key.to_s]
          else
            to_h[key.to_s]
          end
        end

        def []=(key, value)
          data.merge_flat_key! key, value
          ensure!
        end

        def to_h
          data
        end

        def to_yml
          YAML.dump(to_h).sub(/^---\s\n/, '')
        end

        def ensure!
          if path.exist?
            Log.debug "Config file already exists at #{path}".yellow
          else
            Log.info "Creating new example config file at #{path}".green
            Resources::File.write path
          end
          persist!
        end

        private

        def flat_key?(key)
          key.to_s.index('.')
        end

        def persist!
          if path.writable?
            content = [template, to_yml].join("\n\n")
            Resources::File.write path, content
          else
            message = "The configuration file #{path} is not writable."
            Log.error message.red
            raise Errors::ConfigFileNotWritable, message
          end
          Log.debug "Configuration file #{path} updated."
        end

        def data
          @data ||= load
        end

        def load
          if path.readable?
            YAML.load(path.read) || {}
          else
            Log.debug "There is no configuration file located at #{path}. Using default (i.e. empty) configuration."
            {}
          end
        rescue ArgumentError
          message = "The configuration file #{path} has an invalid YAML syntax."
          Log.error message.red
          raise Errors::InvalidConfigYaml, message
        end

        def template
          <<-END.undent
            # In this YAML file you can configure how this sphere is updated.
            # To manage this file manually, simply leave this file empty or delete it.
            #
            # To have a chef server manage this sphere, uncomment the following lines.
            # They are essentialy passed on to knife, see http://docs.opscode.com/config_rb_client.html
            # Important: Make sure that the validation.pem key is located inside the sphere directory!
            #            Alternatively you can specify the "validation_key_path" option to specify the path.
            #
            # manager:
            #   chefserver:
            #     chef_server_url: https://chefserver.example.com
            #     node_name: bobs_macbook.biosphere
            #     env_vars:
            #       ssh_key_name: id_rsa
            #     # override_runlist: "role[biosphere]"  # Uncomment this one to override the runlist assigned to you by the chef server.
            #
            # This following one uses chef-solo.
            # It has pretty much the same options as chefserver (except validation_key, chef_server_url, and override_runlist)
            #
            # manager:
            #   chefsolo:
            #     cookbooks_path: "~/Documents/my_cookbooks"
            #     # runlist: "recipe[biosphere]"  # Uncomment this line to change the default run list
            #
          END
        end

      end
    end
  end
end
