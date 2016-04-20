require 'optparse'
require 'biosphere/errors'
require 'biosphere/extensions/ostruct'
require 'biosphere/actions'
require 'biosphere/version'

module Biosphere
  module Actions
    class Version

      Options = Class.new(OpenStruct)

      def initialize(args = [])
        @args = args
      end

      def call
        return help if Runtime.help_mode?

        if options.short
          Log.info { VERSION }
        else
          Log.info { "Biosphere version #{VERSION}" }
        end
      end

      private

      def help
        Log.separator
        Log.info { '  bio version             Show informational text about version' }
        Log.info { '  bio version --short     Show only version number' }
        Log.separator
      end

      def options
        @options ||= begin
          result = {}
          OptionParser.new do |parser|
            parser.on('--short') { |v| result[:short] = v }
          end.parse!(@args)
          Options.new result
        end
      end

    end
  end
end

Biosphere::Actions.register Biosphere::Actions::Version
