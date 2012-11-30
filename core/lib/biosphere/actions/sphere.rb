require 'optparse'
require 'biosphere/action'
require 'biosphere/log'
require 'biosphere/extensions/option_parser'
require 'biosphere/extensions/ostruct'
require 'biosphere/runtime'
require 'biosphere/resources/sphere'

module Biosphere
  module Actions
    class Sphere

      Options = Class.new(OpenStruct)

      def perform
        return help if Runtime.help_mode?
        subcommand = Runtime.arguments.shift
        case subcommand
        when 'create' then create(Runtime.arguments.shift)
        else               help
        end
      end

      private

      def help
        Log.separator
        Log.info "  Creating a Sphere:".cyan
        Log.info "    bio sphere create my_sphere".bold
        Log.separator
      end

      def create(name)
        Resources::Sphere.new(name).create
      end

      def options
        @options ||= begin
          result = {}
          OptionParser.new do |parser|

            parser.on("--test [SPHERENAME]") do |value|
              result[:test] = value
            end

          end.parse!(Runtime.arguments)
          Options.new result
        end
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Sphere