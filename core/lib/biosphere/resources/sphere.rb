require 'biosphere/error'
require 'biosphere/log'
require 'biosphere/manager'
require 'biosphere/resources/directory'
require 'biosphere/resources/file'
require 'biosphere/extensions/ostruct'
require 'biosphere/extensions/string'
require 'biosphere/extensions/hash'
require 'biosphere/extensions/json'
require 'pathname'
require 'yaml'

module Biosphere
  module Errors
    class InvalidSphereName < Error
      def code() 2 end
    end

    class InvalidManagerConfiguration < Error
      def code() 3 end
    end
  end
end

module Biosphere
  module Resources
    class Sphere
      class Config

        def initialize(config_file_path)
          @config_file_path = config_file_path
        end

      end
    end
  end
end

module Biosphere
  module Resources
    class Sphere

      Config = Class.new(OpenStruct)

      attr_reader :name

      def initialize(name)
        @name = name.to_s
        ensure_valid_name!
      end

      def self.all
        sphere_paths.sort.map { |sphere_path| new(sphere_path.basename) }
      end

      def self.find(name_or_names)
        if name_or_names.is_a?(Array)
          name_or_names.map do |name|
            find name
          end.compact
        else
          all.detect { |sphere| sphere.name == name_or_names }
        end
      end

      def self.augmentations
        result = {}
        all.each do |sphere|
          next unless sphere.activated?
          augmentation_identifiers.each do |identifier|
            result[identifier] = [] unless result[identifier]
            augmentation = sphere.augmentation(identifier)
            if augmentation
              Log.debug "Gathering #{identifier} augmentations from sphere #{sphere.name}..."
              augmentation = "# SPHERE #{sphere.name.upcase}\n\n#{augmentation}"
              if augmentation_prominence?(identifier) == :earlier
                result[identifier].push augmentation
              else
                result[identifier].unshift augmentation
              end
            else
              Log.debug "No #{identifier} augmentations to gather from sphere #{sphere.name}..."
            end
          end
        end
        result
      end

      def self.augmentation_identifiers
        [:bash_profile, :zshenv, :ssh_config]
      end

      def create
        ensure_path
        ensure_config_file
        augmentations_path
      end

      def update
        Log.debug "Initializing update of sphere #{name}..."
        manager.perform
      end

      def configure(options={})
        Resources::File.write(config_file_path, config_example_template) if options == {}
        options = JSON.load(options[:from_json])
        yaml = YAML.dump(options).sub(/^---\s\n/, '')
        content = [config_example_template, yaml].join("\n\n")
        Resources::File.write config_file_path, content
        Log.info "Sphere #{name} updated."
      end

      def cache_path
        Directory.ensure path.join('cache')
      end

      def augmentations_path
        Directory.ensure path.join('augmentations')
      end

      def path
        self.class.spheres_path.join(name)
      end

      def manager
        unless manager = Manager.find(manager_name)
          message = %{The sphere #{name.to_s.inspect} has defined the manager #{manager_name.inspect} in its config file (#{config_file_path}). But that manager could not be found by Biosphere::Manager.}.red
          Log.error message
          raise Errors::InvalidSphereName, message
        end
        manager.new :sphere => self, :config => manager_config
      end

      def as_json
        { :identifier => name, :manager => manager }
      end

      def to_json
        as_json.to_json
      end

      def activated?
        activated_file_path.exist?
      end

      def activate!(index=0)
        Resources::File.write activated_file_path, index
      end

      def deactivate!
        Resources::File.delete activated_file_path
      end

      def activation_order
        return 0 unless activated?
        activated_file_path.read.to_i
      end

      def augmentation(identifier)
        path = augmentations_path.join(identifier.to_s)
        path.exist? ? path.read : nil
      end

      def config_value(key)
        config.to_h.flatten_keys[key]
      end

      def set_config_value(key, value)
        
      end

      private

      def config
        Config.new raw_config
      end

      def ensure_path
        if path.exist?
          Log.info "Sphere #{name.inspect} already exists at #{path}".yellow
        else
          Log.info "Creating new sphere #{name.inspect} at #{path}".green
          Resources::Directory.ensure path
        end
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

      def manager_config
        if manager_name == 'manual'
          Manager::Config.new
        else
          Manager::Config.new config.manager[manager_name]
        end
      end

      def manager_name
        if config.manager
          if config.manager.is_a?(Hash)
            if config.manager.keys.size > 1
              message = %{In your configuration at #{config_file_path} you specified multiple managers (#{config.managers.keys.join(', ')}) but currently biosphere only supports one manager per Spehre}.red
              Log.error message
              raise Errors::InvalidManagerConfiguration, message
            else
              config.manager.keys.first.to_s
            end
          else
            message = %{You specified a "manager" key in your configuration at #{config_file_path} but that key has to be a Hash.}.red
            Log.error message
            raise Errors::InvalidManagerConfiguration, message
          end
        else
          'manual'
        end
      end

      def ensure_valid_name!
        unless valid_name?
          message = %{The sphere name #{name.to_s.inspect} is invalid. It has to follow the same convention as a local ruby variable and has to be lower-case. E.g. "my_sphere". Location: #{path.to_s.inspect}}.red
          Log.error message
          raise Errors::InvalidSphereName, message
        end
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

      def activated_file_path
        path.join(activated_file_name)
      end

      def activated_file_name
        'active'
      end

      def config_file_path
        path.join(config_file_name)
      end

      def config_file_name
        'sphere.yml'
      end

      def self.augmentation_prominence?(identifier)
        case identifier
        when :ssh_config then :earlier # Earlier things in ~/.ssh/config override later things
        else                  :later   # Later things in e.g. ~/.bash_profile override earlier things
        end
      end

      def valid_name?
        name.to_s.match(/^[a-z][a-z0-9_]+[^_]$/) && !name.to_s.match(/__/)
      end

      def self.sphere_paths
        Pathname.glob spheres_path.join('*')
      end

      def self.spheres_path
        Pathname.new BIOSPHERE_SPHERES_PATH
      end

    end
  end
end