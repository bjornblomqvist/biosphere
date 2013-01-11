# Might be nicer to wrap the configuration like this?
#module Biosphere
#  module Resources
#    class Sphere
#      class Config
#
#        def initialize(config_file_path)
#          @config_file_path = config_file_path
#        end
#
#      end
#    end
#  end
#end

module Biosphere
  module Resources
    class Sphere
      module Configurable

        Config = Class.new(OpenStruct)

        def config_value(key)
          config.to_h.flatten_keys[key]
        end

        def set_config_value(key, value)
          configure :from_hash => config.to_h.merge_flat_key!(key, value)
        end

        private

        def configure(options={})
          Resources::File.write(config_file_path, config_example_template) if options == {}
          options = options[:from_hash] || JSON.load(options[:from_json])
          yaml = YAML.dump(options).sub(/^---\s\n/, '')
          Log.info options.inspect
          Log.info yaml.inspect
          content = [config_example_template, yaml].join("\n\n")
          Resources::File.write config_file_path, content
          Log.info "Sphere #{name} updated."
        end

        def config
          Config.new raw_config
        end

        def raw_config
          @raw_config ||= begin
            if config_file_path.readable?
              YAML.load config_file_path.read
            else
              Log.debug "The sphere #{name.inspect} has no YAML configuration file (#{config_file_path}). Using default (i.e. empty) configuration."
              {}
            end
          rescue ArgumentError
            Log.error "The sphere #{name.inspect} has an invalid YAML configuration file: (#{config_file_path})"
            exit 50
          end
        end

        def config_file_name
          'sphere.yml'
        end

        def config_file_path
          path.join(config_file_name)
        end

        def ensure_config_file
          if config_file_path.exist?
            Log.info "Sphere #{name.inspect} already has a config file at #{config_file_path}".yellow
          else
            Log.info "Creating new example config file for sphere #{name.inspect} at #{config_file_path}".green
            Resources::File.write config_file_path, config_example_template
          end
        end

        def config_example_template
          <<-END.undent
            # In this YAML file you can configure how the sphere #{name.inspect} is updated.
            # To manage this file manually, simply leave this file empty or delete it.
            #
            # To have a chef server manage this sphere, uncomment the following lines.
            # They are essentialy passed on to knife, see http://wiki.opscode.com/display/chef/Knife#Knife-Knifeconfiguration
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
            #     cookbook_path: "~/Documents/my_cookbooks"
            #     # runlist: "recipe[biosphere]"  # Uncomment this line to change the default run list
            #
          END
        end

      end
    end
  end
end
