module Biosphere
  module Managers
    module Chefsolos
      class Paths

        def initialize(sphere: nil)
          @sphere = sphere
        end

        def solo_json
          base.join('solo.json')
        end

        def knife_config
          base.join('knife.rb')
        end

        def checksums
          result = workdir.join('checksums')
          result.mkpath
          result
        end

        def cache
          result = workdir.join('cache')
          result.mkpath
          result
        end

        def backups
         result = workdir.join('backups')
         result.mkpath
         result
        end

        private

        attr_reader :sphere

        # Every sphere has a cache. Everything that has to do with chef will be put in there.
        def base
          result = sphere.cache_path.join('chef')
          result.mkpath
          result
        end

        # When running chef, a lot of temporary data is generated.
        # This is where we want that temporary data to be stored.
        def workdir
          result = base.join('cache')
          result.mkpath
          result
        end

      end
    end
  end
end
