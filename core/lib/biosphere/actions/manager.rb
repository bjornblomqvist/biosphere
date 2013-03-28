require 'biosphere/action'
require 'biosphere/manager'

module Biosphere
  module Actions
    # ErrorCodes: 20-29
    class Manager

      def perform(args)
        return help if Runtime.help_mode?
        subcommand = args.shift
        case subcommand
        when 'list' then list
        else             help
        end
      end

      private

      def help
        Log.info "Help..."
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