require 'biosphere/error'
require 'biosphere/log'
require 'biosphere/manager'
require 'biosphere/resources/directory'
require 'biosphere/resources/file'
require 'biosphere/extensions/ostruct'
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

      Config = Class.new(OpenStruct)

      attr_reader :name

      def initialize(name)
        @name = name.to_s
        ensure_valid_name!
      end

      def self.all
        sphere_paths.sort.map { |sphere_path| new(sphere_path.basename) }
      end

      def create
        ensure_path
        ensure_config_file
      end

      def update
        Log.debug "Initializing update of sphere #{name}..."
        manager.perform
      end

      def cache_path
        Directory.ensure path.join('cache')
      end

      def path
        self.class.spheres_path.join(name)
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
        result = <<-END
          # In this YAML file you can configure how the sphere #{name.inspect} is updated.
          # To manage this file manually, simply leave this file empty or delete it.
          #
          # To have a chef server manage this sphere, uncomment the following lines.
          #
          # manager:
          #   chefserver:
          #     chef_server_url: https://chefserver.example.com
          #     validation_key: ~/Documents/validation.pem
          #     node_name: bobs_macbook.biosphere
          #
        END
        result.split("\n").map(&:strip).join("\n")
      end

      def manager
        unless manager = Manager.find(manager_name)
          message = %{The sphere #{name.to_s.inspect} has defined the manager #{manager_name.inspect} in its config file (#{config_file_path}). But that manager could not be found by Biosphere::Manager.}.red
          Log.error message
          raise Errors::InvalidSphereName, message
        end
        manager.new :sphere => self, :config => manager_config
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

      def config_file_path
        path.join(config_file_name)
      end

      def config_file_name
        'sphere.yml'
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