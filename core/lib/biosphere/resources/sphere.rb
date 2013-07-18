require 'biosphere/error'
require 'biosphere/log'
require 'biosphere/manager'
require 'biosphere/paths'
require 'biosphere/extensions/json'
require 'biosphere/resources/sphere/activatable'
require 'biosphere/resources/sphere/augmentable'
require 'biosphere/resources/sphere/configurable'
require 'biosphere/resources/sphere/managable'
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
      def code() 4 end
    end
  end
end

module Biosphere
  module Resources
    class Sphere

      include Configurable
      include Augmentable
      include Activatable
      include Managable

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

      def create
        ensure_path
        ensure_config_file
        augmentations_path
      end

      def update
        Log.debug "Initializing update of sphere #{name}..."
        manager.perform
      end

      def cache_path
        Directory.create path.join('cache')
      end

      def path
        Paths.spheres.join(name)
      end

      def as_json
        { :identifier => name, :manager => manager.as_json, :activated => activated?, :activation_order => activation_order }
      end

      def <=>(other_sphere)
        other_sphere.activation_order <=> self.activation_order
      end

      private

      def ensure_path
        if path.exist?
          Log.info "Sphere #{name.inspect} already exists at #{path}".yellow
        else
          Log.info "Creating new sphere #{name.inspect} at #{path}".green
          Resources::Directory.create path
        end
      end

      def ensure_valid_name!
        unless valid_name?
          message = %{The sphere name #{name.to_s.inspect} is invalid. It has to follow the same convention as a local ruby variable and has to be lower-case. E.g. "my_sphere". Location: #{path.to_s.inspect}}.red
          Log.error message
          raise Errors::InvalidSphereName, message
        end
      end

      def valid_name?
        name.to_s.match(/^[a-z][a-z0-9_]+[^_]$/) && !name.to_s.match(/__/)
      end

      def self.sphere_paths
        Pathname.glob Paths.spheres.join('*')
      end

    end
  end
end