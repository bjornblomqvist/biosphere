require 'optparse'
require 'biosphere/action'
require 'biosphere/log'
require 'biosphere/extensions/option_parser'
require 'biosphere/extensions/ostruct'
require 'biosphere/extensions/json'
require 'biosphere/runtime'
require 'biosphere/resources/sphere'

module Biosphere
  module Errors
    class SphereNotFound < Error
      def code() 30 end
    end
    class ConfigKeyNotFound < Error
      def code() 31 end
    end
  end
end

module Biosphere
  module Actions
    class Sphere

      Options = Class.new(OpenStruct)

      def initialize(args)
        @args = args
      end

      def perform
        return help if Runtime.help_mode?
        case subcommand
        when 'create'    then create
        when 'list'      then list
        when 'show'      then show
        when 'configure' then configure
        when 'config'    then config
        else                  help
        end
      end

      private

      def subcommand
        @args.first
      end

      def parameters
        @args.dup[1..-1]
      end

      def help
        Log.separator
        Log.info "    bio sphere list".bold + "                 Listing all spheres".cyan
        Log.info "    bio sphere show my_sphere".bold + "       Details about one sphere".cyan
        Log.info "    bio sphere create my_sphere".bold + "     Creating a sphere".cyan
        Log.separator
      end

      def list
        Log.separator
        Log.batch Resources::Sphere.all.map(&:as_json).to_json
        Resources::Sphere.all.each do |sphere|
          Log.info "  #{sphere.name.ljust(15).bold}" + " Managed by #{sphere.manager.to_s.bold}".cyan
        end
        Log.separator
      end

      def config
        name, key, new_value = parameters
        sphere = find_sphere!(name)
        Log.info "#{name} - #{key} - #{new_value}"
        if new_value
          sphere.set_config_value(key, new_value)
        elsif value = sphere.config_value(key)
          Log.batch value.to_json
          Log.info value.inspect
        else
          message = "Key #{key.inspect} not found."
          Log.error message
          raise Errors::ConfigKeyNotFound, message
        end
      end

      def show
        sphere = find_sphere!
        Log.batch({ :sphere => sphere.as_json }.to_json)
      end

      def create
        name = parameters.first
        Resources::Sphere.new(name).create
      end

      def configure
        name = parameters.first
        if options.remove_config
          Resources::Sphere.new(name).configure
        else
          Resources::Sphere.new(name).configure :from_json => options.from_json
        end
      end

      def find_sphere!
        name = parameters.first
        unless name
          message = "You must specify a Sphere name."
          Log.error message.red
          raise Errors::SphereNotFound, message
        end
        unless sphere = Resources::Sphere.find(name)
          message = "Sphere #{name.inspect} not found."
          Log.error message.red
          raise Errors::SphereNotFound, message
        end
        sphere
      end

      def options
        @options ||= begin
          result = {}
          OptionParser.new do |parser|

            parser.on("--from-json JSON") do |value|
              result[:from_json] = value
            end

            parser.on("--remove-config") do |value|
              result[:remove_config] = value
            end

          end.parse!(Runtime.arguments)
          Options.new result
        end
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Sphere