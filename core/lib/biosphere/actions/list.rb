require 'optparse'
require 'biosphere/action'
require 'biosphere/log'
require 'biosphere/extensions/option_parser'
require 'biosphere/extensions/ostruct'
require 'biosphere/runtime'
require 'biosphere/resources/sphere'

module Biosphere
  module Actions
    class Sphere

      def initialize(args)
        @args = args
      end

      def call
        return help if Runtime.help_mode?

        case subcommand
        when 'create' then create
        when 'list'   then list
        when 'show'   then show
        else               help
        end
      end

      private

      attr_reader :args

      def subcommand
        args.first
      end

      def parameters
        args.dup[1..-1]
      end

      def help
        Log.separator
        Log.info "    bio sphere list".bold + "                 Listing all spheres".cyan
        Log.info "    bio sphere show my_sphere".bold + "       Details about one sphere".cyan
        Log.info "    bio sphere create my_sphere".bold + "     Creating a sphere".cyan
        Log.separator
      end

      def list
        Log.separator
        Resources::Spheres.all.sort.reverse.each do |sphere|
          name = sphere.name.ljust(15)

          Log.info { "  #{name}" + " Managed by #{sphere.manager.to_s.bold}".cyan }
        end
        Log.separator
      end

      def show
        sphere = find_sphere!
      end

      def create
        name = parameters.first
        Resources::Sphere.new(name).create
      end

      def configure
        name = parameters.first
        if options.remove_config
          Resources::Sphere.new(name).configure
        end
      end


    end
  end
end

Biosphere::Actions.register Biosphere::Actions::Sphere
