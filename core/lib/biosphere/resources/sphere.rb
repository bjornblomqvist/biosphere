require 'biosphere/errors'
require 'biosphere/managers'
require 'biosphere/extensions/string'
require 'biosphere/log'
require 'biosphere/resources/directory'
require 'biosphere/resources/file'
require 'biosphere/resources/spheres/name'
require 'biosphere/resources/spheres/config'
require 'pathname'
require 'ostruct'
require 'yaml'

module Biosphere
  module Resources
    class Sphere

      attr_reader :name

      def initialize(name)
        @raw_name = name
        ensure_valid_name!
      end

      def name
        Spheres::Name.new(raw_name).call
      end

      def create!
        create_directory!
        create_config_file!
        self
      end

      def activated?
        activated_file_path.exist?
      end

      def activate!
        Resources::File.write activated_file_path
      end

      def deactivate!
        Resources::File.delete activated_file_path
      end

      def manager
        @manager ||= manager!
      end

      def update
        Log.debug { "Initializing update of sphere #{name}..." }
        manager.call
      end

      def cache_path
        Directory.create(path.join('cache')).path
      end

      def path
        Paths.spheres.join(name)
      end

      def <=>(other)
        other.name <=> name
      end

      def augmentations_path
        Directory.create(path.join('augmentations')).path
      end

      private

      attr_reader :raw_name

      def ensure_valid_name!
        return if name
        Log.error { %(The sphere name #{raw_name.to_s.inspect} is invalid. (It has to be lower-case. E.g. "my_sphere".)).red }
        raise Errors::InvalidSphereName
      end

      def create_directory!
        if path.exist?
          Log.info { "  Sphere #{name.bold}".yellow + " already exists at ".yellow + path.to_s.yellow.bold }
        else
          Log.info { "  Creating new Sphere #{name.inspect} at ".green + path.to_s.green.bold }
          Resources::Directory.create path
        end
      end

      def create_config_file!
        if config_file_path.exist?
          Log.debug { 'Config file already exists at '.yellow + config_file_path.to_s.yellow.bold }
        else
          Log.info { '  Creating new example config file at '.green + config_file_path.to_s.green.bold }
          Resources::File.write config_file_path, Spheres::Config.template
        end
      end

      def activated_file_path
        path.join 'active'
      end

      def config_file_path
        path.join('sphere.yml')
      end

      def config
        if config_file_path.readable?
          ::YAML.load(config_file_path.read) || {}
        else
          Log.debug { "There is no config file located at #{path}." }
          {}
        end

      rescue Psych::SyntaxError
        Log.error { "The configuration file #{path} has an invalid YAML syntax." }
        raise Errors::InvalidConfigYaml
      end

      def manager_config
        OpenStruct.new config.fetch('manager', {}).fetch(manager_name, {})
      end

      def manager_name
        return 'manual' unless config['manager']

        unless config['manager'].is_a?(Hash)
          Log.error { %{You specified a "manager" key in your configuration at #{config_file_path} but that key has to be a Hash.}.red }
          raise Errors::InvalidManagerConfigurationError
        end

        if config['manager'].keys.size > 1
          Log.error { %{In your configuration at #{config_file_path} you specified multiple managers (#{config['manager'].keys.join(', ')}) but Biosphere only supports one manager per Spehre}.red }
          raise Errors::InvalidManagerConfigurationError
        else
          config['manager'].keys.first.to_s
        end
      end

      def manager!
        manager = Managers.find(manager_name)

        unless manager
          Log.error { %{The sphere #{name.to_s.inspect} has defined the manager #{manager_name.inspect} in its config file (#{config_file_path}). But that manager could not be found by Biosphere::Manager.}.red }
          raise Errors::UnknownManagerError
        end

        manager.new sphere: self, config: manager_config
      end

    end
  end
end
