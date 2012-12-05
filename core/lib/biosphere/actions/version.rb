require 'optparse'
require 'biosphere/error'
require 'biosphere/extensions/ostruct'
require 'biosphere/action'
require 'biosphere/resources/sphere'

module Biosphere
  module Errors
    class IncompatibleBiospherePane < Error
      def code() 70 end
    end
  end
end

module Biosphere
  module Actions
    class Version

      Options = Class.new(OpenStruct)

      def perform
        return help if Runtime.help_mode?
        if options.short
          Log.info VERSION
        elsif options.major
          Log.info Biosphere::Version::MAJOR
        elsif options.minor
          Log.info Biosphere::Version::MINOR
        elsif options.patch
          Log.info Biosphere::Version::PATCH
        elsif version = options.biospherepane
          if compatible_with_biospherepane?(version)
            Log.info "Biosphere #{VERSION} is compatible with BiospherePane #{version}"
          else
            message = "Biosphere #{VERSION} is NOT compatible with BiospherePane #{version}".red
            Log.error message
            raise Errors::IncompatibleBiospherePane, message
          end
        else
          Log.info "Biosphere Version #{VERSION}"
        end
      end

      private

      def compatible_with_biospherepane?(version)
        true
      end

      def help
        Log.separator
        Log.info '  --short     Show only version number'
        Log.info '  --major     Show only major version number'
        Log.info '  --minor     Show only minor version number'
        Log.info '  --patch     Show only patch version number'
        Log.separator
      end

      def options
        @options ||= begin
          result = {}
          OptionParser.new do |parser|

            parser.on("--short") do |value|
              result[:short] = value
            end

            parser.on("--major") do |value|
              result[:major] = value
            end

            parser.on("--minor") do |value|
              result[:minor] = value
            end

            parser.on("--patch") do |value|
              result[:patch] = value
            end

            parser.on("--compatible-with-preference-pane VERSION") do |value|
              result[:biospherepane] = value
            end

          end.parse!(Runtime.arguments)
          Options.new result
        end
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Version