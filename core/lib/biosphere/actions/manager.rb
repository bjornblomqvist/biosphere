require 'biosphere/action'
require 'biosphere/manager'

module Biosphere
  module Actions
    class Manager

      def perform
        return help if Runtime.help_mode?
        subcommand = Runtime.arguments.shift
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