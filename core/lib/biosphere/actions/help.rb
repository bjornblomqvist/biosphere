require 'biosphere/log'

module Biosphere
  module Actions
    class Help

      def initialize(_)
      end

      def call
        Log.separator
        Log.info { "  bio setup".bold }
        Log.separator
        Log.info { "  Examples:".cyan }
        Log.separator
        Log.info { "  bio setup                   ".bold + "".cyan }
        Log.info { "  bio create myproject         ".bold + "".cyan }
        Log.info { "  bio list                  ".bold + "".cyan }
        Log.info { "  bio activate myproject                  ".bold + "".cyan }
        Log.info { "  bio update                  ".bold + "".cyan }
        Log.info { "  bio deactivate                  ".bold + "".cyan }
        Log.info { "  bio implode                  ".bold + "".cyan }
        Log.info { "  bio version                  ".bold + "".cyan }
        Log.separator
      end

    end
  end
end

Biosphere::Actions.register Biosphere::Actions::Help
