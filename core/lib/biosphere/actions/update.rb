require 'biosphere/action'
require 'biosphere/actions/activate'
require 'biosphere/paths'
require 'biosphere/resources/command'
require 'biosphere/spheres'
require 'biosphere/resources/sphere'
require 'biosphere/augmentations'
require 'ostruct'

module Biosphere
  module Actions
    class Update

      Options = Class.new(OpenStruct)

      def initialize(args = [])
        @args = args
      end

      def call
        return help if Runtime.help_mode?

        Log.separator
        if options.system
          update_system
        elsif relevant_spheres.empty?
          if args.empty?
            Log.info { '  You have no Spheres. '.yellow }
            Log.info { '  Try '.yellow + 'bio create --help'.bold.cyan + ' for instructions.'.yellow }
          else
            Log.info { '  The Sphere '.red + args.first.to_s.bold.red + ' does not exist.'.red }
            Log.info { '  Try '.red + 'bio list'.bold.cyan + ' to see your Spheres.'.red }
            Log.separator
            raise Errors::SphereNotFound
          end
        else
          update
          reactivate
        end
        Log.separator
      end

      private

      attr_reader :args

      def help
        'Coming soon ...'
      end

      def update_system
        result = update_command.call
        Log.separator
        if result.success?
          Log.info { '  Biosphere was updated.'.green }
          Log.separator
        else
          Log.error { "  Could not update Biosphere at #{Paths.biosphere_home} \n#{result.indented_output}".red }
          Log.separator
          raise Errors::CouldNotUpdateBiosphere
        end
      end

      def update_command
        git_dir = Paths.biosphere_home.join('.git')
        arguments = %W(--work-tree #{Paths.biosphere_home} --git-dir #{git_dir} pull origin master)
        Resources::Command.new executable: 'git', arguments: arguments, show_output: true
      end

      def update
        relevant_spheres.each do |sphere|
          result = sphere.update
          next unless result
          if result.success?
            Log.info { "  Successfully updated Sphere #{sphere.name.bold}".green }
          else
            Log.error { "  There were problems updating the Sphere #{sphere.name.bold}".red }
          end
          Log.separator
        end
      end

      def reactivate
        Action.new(['activate']).call
      end

      def relevant_spheres
        if args.empty?
          Spheres.all
        else
          [Spheres.find(args.first)].compact
        end
      end

      def options
        @options ||= begin
          result = {}
          OptionParser.new do |parser|

            parser.on('--system') do |value|
              result[:system] = value
            end

          end.parse!(args)
          Options.new result
        end
      end

    end
  end
end

Biosphere::Actions.register Biosphere::Actions::Update
