require 'biosphere/resources/path'

module Biosphere
  module Resources
    class Directory < Path

      private

      def create!
        Log.debug "Creating directory #{path}"
        path.mkdir
      end

    end
  end
end
