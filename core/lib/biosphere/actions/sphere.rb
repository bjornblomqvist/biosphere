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
  end
end

module Biosphere
  # ErrorCodes: 30-39
  module Actions
    class Sphere

      Options = Class.new(OpenStruct)

      def perform(args)
        return help if Runtime.help_mode?
        subcommand = args.shift
        case subcommand
        when 'create'    then create(args.shift)
        when 'list'      then list
        when 'show'      then show(args.shift)
        when 'configure' then configure(args.shift)
        else                  help
        end
      end

      private

      def help
        Log.separator
        Log.info "  Creating a Sphere:".cyan
        Log.info "    bio sphere create my_sphere".bold
        Log.separator
      end

      def list
        Log.separator
        Log.batch Resources::Sphere.all.map(&:name).to_json
        Resources::Sphere.all.each do |sphere|
          #Log.batch sphere.name
          Log.info "  #{sphere.name.ljust(15).bold}  # Managed by #{sphere.manager}"
        end
        Log.separator
      end

      def show(name)
        unless sphere = Resources::Sphere.all.detect { |sphere| sphere.name == name }
          message = "Sphere #{name.inspect} not found"
          Log.error message
          raise Errors::SphereNotFound, message
        end
        Log.batch sphere.to_json
      end

      def create(name)
        Resources::Sphere.new(name).create
      end

      def configure(name)
        if options.remove_config
          Resources::Sphere.new(name).configure
        else
          Resources::Sphere.new(name).configure :from_json => options.from_json
        end
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