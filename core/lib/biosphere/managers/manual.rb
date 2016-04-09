require 'biosphere/log'
require 'biosphere/managers/default'

module Biosphere
  module Managers
    class Manual < Default

      def call
        Log.info "Not updating sphere #{sphere.name.bold} because it is handled manually."
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
