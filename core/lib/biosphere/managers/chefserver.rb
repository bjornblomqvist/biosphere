require 'biosphere/managers/default'
require 'biosphere/gem'

module Biosphere
  module Managers
    class Chefserver < Default

      def perform
        Log.debug "Manager #{name} will now update sphere #{sphere.name}..."
        ensure_chef
        Log.debug "yo #{chef_client_executable_path}"
      end

      private

      def chef_client_executable_path
        chef_gem.executables_path.join('chef-client')
      end

      def ensure_chef
        chef_gem.ensure
      end

      def chef_gem
        @chef_gem ||= Gem.new(:name => :chef, :version => chef_version)
      end

      def chef_version
        sphere.config.chef_version || default_chef_version
      end

      def default_chef_version
        '10.12.0'
      end

    end
  end
end

Biosphere::Manager.register Biosphere::Managers::Chefserver