#require 'optparse'
#require 'biosphere/action'
require 'biosphere/log'
#require 'biosphere/extensions/option_parser'
#require 'biosphere/extensions/ostruct'
require 'biosphere/runtime'
require 'biosphere/resources/sphere'

module Biosphere
  module Actions
    class Create

      def initialize(args = [])
        @args = args
      end

      def call
        return help if Runtime.help_mode? || !sphere_name

        Log.separator
        Log.separator
      end

      private

      attr_reader :args

      def help
        Log.separator
        Log.info { "    bio create my_sphere".bold + "     Creates a sphere".cyan }
        Log.separator
      end

      def create!
        Resources::Sphere.new(sphere_name).create!
      end

      def sphere_name
        Spheres::Name.new(args.first).call
      end

    end
  end
end

Biosphere::Actions.register Biosphere::Actions::Create
