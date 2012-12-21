module Biosphere
  module Errors
    # The Parent of all Biosphere-related errors
    class Error < StandardError

      # 0 = no errors
      # 1 = uncaught, abnormal error
      # 2 or higher = biosphere errors
      def code
        2
      end

    end
  end
end