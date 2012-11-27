module Biosphere
  module Managers
    class Default

      def initialize(options={})
        @sphere = options[:sphere]
      end

      def perform
        Log.info "Not updating sphere #{sphere.name} because it is handled manually."
      end

      private

      def name
        self.class.name.split('::').last
      end

      def sphere
        @sphere
      end

    end
  end
end