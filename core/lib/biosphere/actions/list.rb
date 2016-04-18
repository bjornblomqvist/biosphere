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
        list
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
        Spheres.all.sort.reverse.each do |sphere|
          name = sphere.name.ljust(15)

          Log.info { "  #{name}" + " Managed by #{sphere.manager.to_s.bold}".cyan }
        end
      end

    end
  end
end

Biosphere::Actions.register Biosphere::Actions::List
