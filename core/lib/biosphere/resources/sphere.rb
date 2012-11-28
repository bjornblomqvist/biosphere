require 'biosphere/error'
require 'biosphere/log'
require 'biosphere/manager'
require 'pathname'
require 'ostruct'
require 'yaml'

module Biosphere
  module Errors
    class InvalidSphereName < Error
      def code() 2 end
    end
  end
end

module Biosphere
  module Resources
    class Sphere
      attr_reader :name

      def initialize(name)
        @name = name.to_s
        ensure_valid_name!
      end

      def self.all
        sphere_paths.sort.map { |sphere_path| new(sphere_path.basename) }
      end

      def update
        Log.debug "Initializing update of sphere #{name}..."
        manager.perform
      end

      def config
        OpenStruct.new raw_config
      end

      private

      def path
        self.class.spheres_path.join(name)
      end

      def manager
        unless manager = Manager.find(manager_name)
          message = %{The sphere #{name.to_s.inspect} has defined the manager #{manager_name.inspect} in its config file (#{config_file}). But that manager could not be found by Biosphere::Manager.}.red
          Log.error message
          raise Errors::InvalidSphereName, message
        end
        manager.new :sphere => self
      end

      def manager_name
        config.manager || 'manual'
      end

      def ensure_valid_name!
        unless valid_name?
          message = %{The sphere name #{name.to_s.inspect} is invalid. It has to follow the same convention as a local ruby variable and has to be lower-case. E.g. "my_sphere". Location: #{path.to_s.inspect}}.red
          Log.error message
          raise Errors::InvalidSphereName, message
        end
      end

      def raw_config
        if config_file.readable?
          YAML.load config_file.read
        else
          Log.debug "The sphere #{name.inspect} has no YAML configuration file (#{config_file}). Using default (i.e. empty) configuration."
          {}
        end
      rescue ArgumentError
        Log.error "The sphere #{name.inspect} has an invalid YAML configuration file: (#{config_file})"
        exit 50
      end

      def config_file
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