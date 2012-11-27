require 'biosphere/managers/default'
require 'biosphere/gem'

module Biosphere
  module Managers
    class Chefserver < Default

      def perform
        Log.debug "Manager #{name} will now update sphere #{sphere.name}..."
        Log.debug "yo"
        ensure_chef
      end

      private

      def ensure_chef
        chef_gem.ensure
      end

      def chef_gem
        @chef_gem ||= Gem.new(:name => 'chef', :version => '10.12.0')
      end

    end
  end
end

Biosphere::Manager.register Biosphere::Managers::Chefserver