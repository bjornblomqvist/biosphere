require 'pathname'
require 'biosphere/resources/command'
require 'biosphere/errors'

module Biosphere
  module Resources
    class Gem
      attr_reader :name, :version

      def initialize(options={})
        @name = options[:name]
        @version = options[:version]
      end

      def call
        return true if exists?
        Log.info { "Installing gem #{name.to_s.bold} version #{version.bold}..." }
        Log.info { 'This may take a while...' }
        install.success?
      end

      def exists?
        gem_path.exist?
      end

      def executables_path
        gem_path.join 'bin'
      end

      private

      def gem_path
        self.class.gems_path.join(name_and_version)
      end

      def install
        result = command.call

        if result.success?
          Log.debug { "Successfully installed gem #{name.to_s.bold} version #{version.bold}" }
        else
          Log.separator
          Log.error { "  Could not install gem #{name.to_s.bold}".red + ' version '.red + version.bold.red + '. Are you online?'.red }
          Log.error { '  Please try to run this command with the'.red + ' --debug '.bold.red + 'flag for more details.'.red }
          Log.separator
          raise Errors::GemInstallationFailed
        end
        result
      end

      def command
        Resources::Command.new env_vars: env_vars, executable: Paths.gem_executable, arguments: arguments
      end

      def arguments
        arguments = %W{ install #{name} --install-dir #{Paths.vendor_gems} --no-document --source https://rubygems.org}
        if version
          arguments << '--version'
          arguments << version
        end
        if Runtime.debug_mode?
          arguments << '--verbose'
        end
        arguments
      end

      def env_vars
        { GEM_PATH: Paths.vendor_gems }
      end

      def name_and_version
        "#{name}-#{version}"
      end

      def self.gems_path
        Paths.vendor_gems.join 'gems'
      end

    end
  end
end
