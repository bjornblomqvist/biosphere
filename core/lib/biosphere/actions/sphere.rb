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
        if options.to_h.empty? || options.help
          help
        elsif options.create
          create
        end
      end

      private

      def help
        Log.separator
        Log.info "  Creating a Sphere:".cyan
        Log.info "    bio sphere --create my_sphere".bold
        Log.separator
      end

      def create
        Resources::Sphere.new(options.create).create
      end

      def options
        @options ||= begin
          result = {}
          OptionParser.new do |parser|

            parser.on("--create [SPHERENAME]") do |value|
              result[:create] = value
            end

            parser.on("--help") do
              result[:help] = true
            end

          end.parse!(Runtime.arguments)
          Options.new result
        end
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Sphere