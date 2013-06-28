require 'biosphere/action'
require 'biosphere/manager'

module Biosphere
  module Actions
    class Manager

      def initialize(args)
        @args = args
      end

      def perform
        return help if Runtime.help_mode?
        case subcommand
        when 'list' then list
        else             help
        end
      end

      private

      def subcommand
        @args.dup.shift
      end

      def help
        Log.separator
        Log.info '  manager list'.bold + '       Lists all available sphere managers'.cyan
        Log.separator
      end

      def list
        Log.separator
        Biosphere::Manager.all.each do |manager|
          Log.batch manager.new
          Log.info "   #{manager.new}"
        end
        Log.separator
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Manager
