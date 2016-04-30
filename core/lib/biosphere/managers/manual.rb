require 'biosphere/log'
require 'biosphere/manager'

module Biosphere
  module Managers
    class Manual

      include ::Biosphere::Manager

      def call
        Log.info { "  Not updating sphere #{sphere.name.bold}".yellow + " because it is handled manually.".yellow }
      end

      def name
        'Manually'
      end

      def description
        'This Manager does perform anything and expects that you handle the sphere updates yourself.'
      end

    end
  end
end

Biosphere::Managers.register Biosphere::Managers::Manual
