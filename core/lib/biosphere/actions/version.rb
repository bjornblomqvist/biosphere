require 'optparse'
require 'biosphere/error'
require 'biosphere/extensions/ostruct'
require 'biosphere/action'
require 'biosphere/version'

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

      def initialize(args)
        @args = args
      end

      def perform
        return help if Runtime.help_mode?
        if options.short
          Log.info VERSION
        elsif options.major
          Log.batch Biosphere::Version::MAJOR
          Log.info Biosphere::Version::MAJOR
        elsif options.minor
          Log.batch Biosphere::Version::MINOR
          Log.info Biosphere::Version::MINOR
        elsif options.patch
          Log.batch Biosphere::Version::TINY
          Log.info Biosphere::Version::TINY
        elsif version = options.pane_version
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
          Log.batch message.to_json
          Log.info message.green
        elsif major.to_i > Biosphere::Version::MAJOR || major.to_i == Biosphere::Version::MAJOR && minor.to_i > Biosphere::Version::MINOR
          message = "Your Preference Pane #{version} is too new for Biosphere #{VERSION}. Please update your Biosphere installation."
          Log.batch message.to_json
          Log.error message.red
          raise Errors::BiospherePaneIsTooNew, message
        elsif major.to_i < Biosphere::Version::MAJOR || major.to_i == Biosphere::Version::MAJOR && minor.to_i < Biosphere::Version::MINOR
          message = "Biosphere #{VERSION} is too new for Preference Pane #{version}. Please upgrade your Preference Pane."
          Log.batch message.to_json
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
            parser.on("--short") { |v| result[:short] = v }
            parser.on("--major") { |v| result[:major] = v }
            parser.on("--minor") { |v| result[:minor] = v }
            parser.on("--patch") { |v| result[:patch] = v }
            parser.on("--compatible-with-preference-pane VERSION") { |v| result[:pane_version] = v }
          end.parse!(@args)
          Options.new result
        end
      end

    end
  end
end

Biosphere::Action.register Biosphere::Actions::Version
