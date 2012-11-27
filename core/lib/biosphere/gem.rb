require 'pathname'
require 'biosphere/command'

module Biosphere
  class Gem
    attr_reader :name, :version

    def initialize(options={})
      @name = options[:name]
      @version = options[:version]
    end

    def ensure
      unless exists?
        Log.info "Installing gem #{name} version #{version}..."
        install
      end
    end

    def exists?
      lib_path.exist?
    end

    private

    def lib_path
      self.class.gem_libs_path.join(name_and_version)
    end

    def install
      arguments = ['install', name, '--install-dir', self.class.gems_path, '--no-ri', '--no-rdoc']
      if version
        arguments << '--version'
        arguments << version
      end
      Command.run(self.class.gem_executable_path, arguments)
    end

    def name_and_version
      "#{name}-#{version}"
    end

    def self.gem_executable_path
      Pathname.new BIOSPHERE_GEM_EXECUTABLE_PATH
    end

    def self.gems_path
      Pathname.new BIOSPHERE_VENDOR_GEMS_PATH
    end

    def self.gem_libs_path
      gems_path.join('gems')
    end

  end
end