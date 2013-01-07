require 'optparse'
require 'biosphere/error'
require 'biosphere/extensions/ostruct'
require 'biosphere/action'
require 'biosphere/version'
require 'biosphere/resources/sphere'

module Biosphere
  module Errors
    class BiospherePaneIsTooNew < Error
      def code() 50 end
    end
    class BiospherePaneIsTooOld < Error
      def code() 51 end
    end
  end
end

module Biosphere
  # ErrorCodes: 50-59
  module Actions
    class Version

      Options = Class.new(OpenStruct)

      def perform(args)
        @args = args
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
          compatibility_notice(version)
        else
          Log.info "Biosphere Version #{VERSION}"
        end
      end

      private

      def compatibility_notice(version)
        major, minor, patch = version.to_s.split('.')
        if major.to_i == Biosphere::Version::MAJOR && minor.to_i == Biosphere::Version::MINOR
          message = "Biosphere #{VERSION} is compatible with BiospherePane #{version}"
          Log.batch message
          Log.info message.green
        elsif major.to_i > Biosphere::Version::MAJOR || major.to_i == Biosphere::Version::MAJOR && minor.to_i > Biosphere::Version::MINOR
          message = "Your Preference Pane #{version} is too new for Biosphere #{VERSION}. Please update your Biosphere installation."
          Log.batch message
          Log.error message.red
          raise Errors::BiospherePaneIsTooNew, message
        elsif major.to_i < Biosphere::Version::MAJOR || major.to_i == Biosphere::Version::MAJOR && minor.to_i < Biosphere::Version::MINOR
          message = "Biosphere #{VERSION} is too new for Preference Pane #{version}. Please upgrade your Preference Pane."
          Log.batch message
          Log.error message.red
          raise Errors::BiospherePaneIsTooOld, message
        end
      end

      def help
        Log.separator
        Log.info '  --short     Show only version number'
        Log.info '  --major     Show only major version number'
        Log.info '  --minor     Show only minor version number'
        Log.info '  --patch     Show only patch version number'
        Log.separator
        Log.info '  --compatible-with-preference-pane VERSION     Is this Biosphere compatible with the specified version of BiospherePane?'
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

          end.parse!(@args)
          Options.new result
        end
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Version
