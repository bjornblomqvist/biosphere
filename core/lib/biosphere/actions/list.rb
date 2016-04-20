require 'optparse'
require 'biosphere/action'
require 'biosphere/actions'
require 'biosphere/spheres'
require 'biosphere/log'
require 'biosphere/extensions/option_parser'
require 'biosphere/runtime'
require 'biosphere/resources/sphere'

module Biosphere
  module Actions
    class List

      def initialize(_ = nil)
      end

      def call
        return help if Runtime.help_mode?

        Log.separator
        if spheres.empty?
          Log.info { '  You have no Spheres. '.yellow }
          Log.info { '  Try '.yellow + 'bio create --help'.bold.cyan + ' for instructions.'.yellow }
        else
          list
        end
        Log.separator
      end

      private

      attr_reader :args

      def help
        Log.separator
        Log.info { "    bio list".bold + "        Listing all spheres".cyan }
        Log.separator
      end

      def list
        spheres.each do |sphere|
          name = sphere.name.ljust(15)

          Log.info { "  #{name}" + " Managed by #{sphere.manager.to_s.bold}".cyan }
        end
      end

      def spheres
        Spheres.all.sort.reverse
      end

    end
  end
end

Biosphere::Actions.register Biosphere::Actions::List
