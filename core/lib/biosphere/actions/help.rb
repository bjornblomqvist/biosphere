require 'optparse'
require 'biosphere/errors'
require 'biosphere/extensions/ostruct'
require 'biosphere/actions'
require 'biosphere/version'

module Biosphere
  module Actions
    class Help

      Options = Class.new(OpenStruct)

      def initialize(args)
        @args = args
      end

      def call
        return help #if Runtime.help_mode?

        #Log.info { "Biosphere Version #{VERSION}" }
      end

      private

      def help
        Log.separator
        Log.info { 'Overview...' }
       # Log.error { 'Do you need help for... the help command?' }
        Log.separator
      end

      def options
        @options ||= begin
          result = {}
          OptionParser.new do |parser|
          end.parse!(@args)
          Options.new result
        end
      end

    end
  end
end

Biosphere::Actions.register Biosphere::Actions::Help
