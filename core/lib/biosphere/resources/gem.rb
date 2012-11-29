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
        unless exists?
          Log.info "Installing gem #{name} version #{version}..."
          install
        end
      end

      def exists?
        gem_path.exist?
      end

      def executables_path
        gem_path.join('bin')
      end

      private

      def gem_path
        self.class.gems_path.join(name_and_version)
      end

      def install
        arguments = ['install', name, '--install-dir', self.class.rubygems_path, '--no-ri', '--no-rdoc']
        if version
          arguments << '--version'
          arguments << version
        end
        Resources::Command.run :executable => self.class.gem_executable_path, :arguments => arguments
      end

      def name_and_version
        "#{name}-#{version}"
      end

      def self.gem_executable_path
        Pathname.new BIOSPHERE_GEM_EXECUTABLE_PATH
      end

      def self.rubygems_path
        Pathname.new BIOSPHERE_VENDOR_GEMS_PATH
      end

      def self.gems_path
        rubygems_path.join('gems')
      end

    end
  end
end