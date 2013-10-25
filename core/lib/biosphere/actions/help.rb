require 'optparse'
require 'biosphere/error'
require 'biosphere/extensions/ostruct'
require 'biosphere/extensions/json'
require 'biosphere/action'
require 'biosphere/version'


module Biosphere
  module Actions
    class Help

      Options = Class.new(OpenStruct)

      def initialize(args)
        @args = args
      end

      def perform
        return help if Runtime.help_mode?

        Log.info "Biosphere Version #{VERSION} Help"
      end

      private

      def help
        Log.separator
        Log.error 'Do you need help for... the help command?'
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

Biosphere::Action.register Biosphere::Actions::Help
