module Biosphere
  module Errors
    # The Parent of all Biosphere-related errors
    class Error < StandardError

      def code
        1
      end

    end
  end
end