module Biosphere
  module Managers
    class Default

      def initialize(options={})
        @sphere = options[:sphere]
        @config = options[:config]
      end

      def perform
        Log.info "Not updating sphere #{sphere.name.bold} because #{self.class.name} does not implement anything useful."
      end

      private

      def name
        self.class.name.split('::').last
      end

      def sphere
        @sphere
      end

      def config
        @config
      end

    end
  end
end