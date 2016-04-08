require 'pathname'
require 'biosphere/errors'
require 'biosphere/extensions/pathname'

module Biosphere
  module Paths

    # ––––––––
    # Settings
    # ––––––––

    def self.biosphere_home=(path)
      @biosphere_home = path
    end

    def self.biosphere_home
      raise Errors::BiosphereHomeNotSetError unless @biosphere_home
      Pathname.new @biosphere_home
    end

    # –––––––––––––––
    # Biosphere Paths
    # –––––––––––––––

    def self.augmentations
      biosphere_home.join 'augmentations'
    end

    def self.shell_augmentation
      augmentations.join 'shell'
    end

    def self.ssh_config_augmentation
      augmentations.join 'ssh_config'
    end

    def self.spheres
      biosphere_home.join 'spheres'
    end

    def self.core_bin
      biosphere_home.join 'core/bin'
    end

    def self.vendor_gems
      biosphere_home.join "vendor/gems/#{RUBY_VERSION}"
    end

    # ––––––––––––
    # System Paths
    # ––––––––––––

    def self.bash_profile
      Pathname.home_path.join('.bash_profile')
    end

    def self.zshenv
      Pathname.home_path.join('.zshenv')
    end

    def self.ruby_executable
      Pathname.new '/usr/bin/ruby'
    end

    def self.gem_executable
      Pathname.new '/usr/bin/gem'
    end

  end
end
