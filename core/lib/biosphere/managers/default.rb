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

      def to_s
        name
      end

      def description
        name
      end

      def as_json
        { :identifier => name, :description => description, :config => config }
      end

      def to_json
        as_json.to_json
      end

      private

      def name
        self.class.name.split('::').last.downcase
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