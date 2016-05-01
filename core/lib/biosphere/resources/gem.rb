require 'pathname'
require 'biosphere/resources/command'
require 'biosphere/errors'

module Biosphere
  module Resources
    class Gem

      def initialize(name: nil, version: nil)
        @name = name.to_s
        @version = version
      end

      def call
        install unless exists?
      end

      def exists?
        path.exist?
      end

      def executables_path
        path.join 'bin'
      end

      private

      attr_reader :name, :version

      def path
        gems_path.join(name_and_version)
      end

      def install
        if install!.success?
          Log.debug { "Successfully installed gem #{name.inspect}#{version_sentence}" }
        else
          fail!
        end
      end

      def install!
        Log.info { "Installing gem #{name.inspect}#{version_sentence}..." }
        Log.info { 'This may take a while...' }
        command.call
      end

      def command
        Resources::Command.new env_vars: env_vars, executable: Paths.gem_executable, arguments: arguments
      end

      def arguments
        arguments = default_arguments
        if version
          arguments << '--version'
          arguments << version
        end
        arguments.push('--verbose') if Runtime.debug_mode?
        arguments
      end

      def default_arguments
        %W(install #{name} --install-dir #{Paths.vendor_gems} --no-document --source https://rubygems.org)
      end

      def fail!
        Log.separator
        Log.error { "Could not install gem #{name.inspect}#{version_sentence}. Are you online?".red }
        Log.error { 'Please try to run this command with the --debug flag for more details.'.red }
        Log.separator
        raise Errors::GemInstallationFailed
      end

      def env_vars
        { GEM_PATH: Paths.vendor_gems }
      end

      def name_and_version
        "#{name}-#{version}"
      end

      def version_sentence
        " version #{version.inspect}" if version
      end

      def gems_path
        Paths.vendor_gems.join 'gems'
      end

    end
  end
end
