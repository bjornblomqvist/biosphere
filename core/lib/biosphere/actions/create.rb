require 'biosphere/log'
require 'biosphere/resources/sphere'
require 'biosphere/runtime'

module Biosphere
  module Actions
    class Create

      def initialize(args = [])
        @args = args
      end

      def call
        return help if Runtime.help_mode? || args.empty?

        Log.separator
        create!
        Log.separator
      end

      private

      attr_reader :args

      def help
        Log.separator
        Log.info { '    bio create myproject'.bold + '     Creates a sphere'.cyan }
        Log.separator
      end

      def create!
        Resources::Sphere.new(args.first).create!
      end

    end
  end
end

Biosphere::Actions.register Biosphere::Actions::Create
