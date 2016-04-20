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
        if result.success?
          Log.info { '  Biosphere was updated.' }
        else
          Log.separator
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
          if result
            if result.success?
              Log.info { "Successfully updated Sphere #{sphere.name.bold}" }
            else
              Log.error { "There were problems updating the Sphere #{sphere.name.bold}".red }
            end
            Log.separator
          else
            # Sphere is handled manually
          end
        end
      end

      def reactivate
        Action.new(['activate']).call
      end

      def relevant_spheres
        if args.empty?
          Spheres.all
        else
          Resources::Sphere.find(name)
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
