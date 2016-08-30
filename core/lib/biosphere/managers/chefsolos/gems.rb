require 'biosphere/resources/gem'

module Biosphere
  module Managers
    module Chefsolos
      # The goal of this class is to provide us with the `chef-solo` executable.
      # It does so by installing the `chef` gem and potential dependencies.
      class Gems

        def initialize(version: default_chef_version)
          @version = version
        end

        def call
          rack_gem.call if native?
          ffi_yajl_gem.call if native?
          chef_zero_gem.call if native?
          chef_gem.call
        end

        def version
          @version || default_chef_version
        end

        def native?
          version == default_chef_version
        end

        def chef_solo_executable
          chef_gem.executables_path.join 'chef-solo'
        end

        private

        # The gem `chef-zero` is a dependency of chef. This is the last version to support Ruby 2.0.0
        # Without specifying this version, it will install one that is too new for Ruby 2.0.0
        def chef_zero_gem
          Resources::Gem.new name: 'chef-zero', version: '4.5.0'
        end

        # The same is true for ffi-yajl, version 2.2.3 is the last one to support Ruby 2.0.0.
        def ffi_yajl_gem
          Resources::Gem.new name: 'ffi-yajl', version: '2.2.3'
        end

        # And rack as well. 1.6.4 is the last one to support Ruby 2.0.0.
        def rack_gem
          Resources::Gem.new name: :rack, version: '1.6.4'
        end

        # Make sure it's compatible with the minimal Ruby version that Biosphere itself requires.
        def default_chef_version
          '12.8.1'
        end

      end
    end
  end
end
