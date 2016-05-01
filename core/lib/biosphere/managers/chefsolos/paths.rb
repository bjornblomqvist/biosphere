module Biosphere
  module Managers
    module Chefsolos
      class Paths

      def initialize(sphere:)
        @sphere = sphere
      end

      def solo_json
        workdir_path.join('solo.json')
      end

      def knife_config
        workdir_path.join('knife.rb')
      end

      def checksums
        result = chef_workdir_path.join('checksums')
        result.mkpath
        result
      end

      def cache
        result = chef_workdir_path.join('cache')
        result.mkpath
        result
      end

      def backups
       result = chef_workdir_path.join('backups')
       result.mkpath
       result
      end

      private

      attr_reader :sphere_name

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
