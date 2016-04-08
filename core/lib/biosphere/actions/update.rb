require 'biosphere/action'
require 'biosphere/actions/activate'
require 'biosphere/paths'
require 'biosphere/resources/sphere'
require 'biosphere/augmentations'

module Biosphere
  module Errors
    class CouldNotUpdateBiosphere < Error
      def code() 40 end
    end
  end
end

module Biosphere
  module Actions
    class Update

      Options = Class.new(OpenStruct)

      def initialize(args)
        @args = args
      end

      def perform
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

      def help
        'Coming soon ...'
      end

      def update_system
        work_tree = Paths.biosphere_home
        git_dir = work_tree.join('.git')
        result = Resources::Command.run :executable => 'git', :arguments => %W{ --work-tree #{work_tree} --git-dir #{git_dir} pull origin master }, :show_output => true
        if result.success?
          Log.info "Biosphere was updated."
        else
          message = "Could not update Biosphere: #{result.stdout.strip} #{result.stderr.strip}"
          Log.error message
          raise Errors::CouldNotUpdateBiosphere, message
        end
      end

      def reactivate
        Action.perform %w{ activate }
      end

      def relevant_spheres
        if @args.empty?
          Resources::Sphere.all
        else
          @args.map do |name|
            Resources::Sphere.find(name)
          end.compact
        end
      end

      def update
        relevant_spheres.each do |sphere|
          result = sphere.update
          if result
            if result.success?
              Log.info "Successfully updated Sphere #{sphere.name.bold}"
            else
              Log.error "There were problems updating the Sphere #{sphere.name.bold}".red
            end
            Log.separator
          else
            # Sphere is handled manually
          end
        end
      end

      def options
        @options ||= begin
          result = {}
          OptionParser.new do |parser|

            parser.on('--system') do |value|
              result[:system] = value
            end

          end.parse!(@args)
          Options.new result
        end
      end

    end
  end
end

Biosphere::Actions.register Biosphere::Actions::Update
