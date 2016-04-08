require 'biosphere/errors'

module Biosphere
  module Errors

    # The Parent of all Biosphere-related errors
    class Error < StandardError
      def code
        raise NotImplementedError
      end
    end

    # User pressed CTRL+C
    class InterruptError < Error
      def code
        130
      end
    end

    # Bio executable was run with elevated privileges.
    class SuperuserManiacError < Error
      def code
        99
      end
    end

    # Bio does not know which action to perform
    class UnknownActionError < Error
      def code
        100
      end
    end

    # Bio setup was unable to write to .bash_profile or .zshenv
    class CouldNotAugmentProfile < Error
      def code
        60
      end
    end

  end
end
