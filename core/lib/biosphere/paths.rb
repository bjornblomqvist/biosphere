require 'pathname'

module Biosphere
  module Paths
    extend self

    BiosphereHomeNotSetError = Class.new(StandardError)

    def biosphere_home=(path)
      @biosphere_home = path
    end

    def biosphere_home
      raise BiosphereHomeNotSetError unless @biosphere_home
      Pathname.new @biosphere_home
    end

    def augmentations
      biosphere_home.join 'augmentations'
    end

    def spheres
      biosphere_home.join 'spheres'
    end

    def core
      biosphere_home.join 'core'
    end

    def vendor
      biosphere_home.join 'vendor'
    end

    def core_lib
      core.join 'lib'
    end

    def core_bin
      core.join 'bin'
    end

    def vendor_gems
      vendor.join 'gems'
    end

    # –––––––––––––––––––
    # Static System Paths
    # –––––––––––––––––––

    def ruby_executable
      Pathname.new '/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/ruby'
    end

    def gem_executable
      Pathname.new '/System/Library/Frameworks/Ruby.framework/Versions/1.8/usr/bin/gem'
    end

  end
end
