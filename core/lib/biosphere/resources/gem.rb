require 'pathname'
require 'biosphere/resources/command'

module Biosphere
  module Resources
    class Gem
      attr_reader :name, :version

      def initialize(options={})
        @name = options[:name]
        @version = options[:version]
      end

      def ensure_installed
        return true if exists?
        Log.info "Installing gem #{name.to_s.bold} version #{version.bold}..."
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
        arguments = %W{ install #{name} --install-dir #{self.class.rubygems_path} --no-ri --no-rdoc --source https://rubygems.org }
        if version
          arguments << '--version'
          arguments << version
        end
        if Runtime.debug_mode?
          arguments << '--verbose'
        end
        result = Resources::Command.run :executable => Paths.gem_executable, :arguments => arguments
        if result.success?
          Log.debug "Successfully installed gem #{name.to_s.bold} version #{version.bold}"
        else
          Log.error "Could not install gem #{name.to_s.bold}".red + ' version '.red + version.bold.red + '. Are you online?'.red
        end
        result
      end

      def name_and_version
        "#{name}-#{version}"
      end

      def self.rubygems_path
        Paths.vendor_gems
      end

      def self.gems_path
        Paths.vendor_gems.join 'gems'
      end

    end
  end
end