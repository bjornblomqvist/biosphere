require 'pathname'

module Biosphere
  module Paths
    extend self

    BiosphereHomeNotSetError = Class.new(StandardError)

    # ––––––––
    # Settings
    # ––––––––

    def biosphere_home=(path)
      @biosphere_home = path
    end

    def biosphere_home
      raise BiosphereHomeNotSetError unless @biosphere_home
      Pathname.new @biosphere_home
    end

    # –––––––––––––
    # Derived Paths
    # –––––––––––––

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
      vendor.join "gems/#{RUBY_VERSION}"
    end

    # –––––––––––––––––––
    # Static System Paths
    # –––––––––––––––––––

    def ruby_executable
      return unless ruby_path
      ruby_path.join 'usr/bin/ruby'
    end

    def gem_executable
      return unless ruby_path
      ruby_path.join 'usr/bin/gem'
    end

    private

    def ruby_path
      %w{ 2.1 2.0 1.9 1.8 }.each do |version|
        path = Pathname.new "/System/Library/Frameworks/Ruby.framework/Versions/#{version}"
        return path if path.exist?
      end
    end

  end
end
