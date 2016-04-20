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
        2
      end
    end

    # Bio executable was run with elevated privileges.
    class SuperuserManiacError < Error
      def code
        3
      end
    end

    # Bio does not know which action to perform
    class UnknownActionError < Error
      def code
        4
      end
    end

    # Cannot determine where the biosphere directory is located
    class BiosphereHomeNotSetError < Error
      def code
        5
      end
    end

    # Bio setup was unable to write to .bash_profile or .zshenv
    class CouldNotAugmentProfile < Error
      def code
        20
      end
    end

    # Creation of Spheres requires some naming conventions.
    class InvalidSphereName < Error
      def code
        25
      end
    end

    class SphereNotFound < Error
      def code
        30
      end
    end

    class ConfigKeyNotFound < Error
      def code
        31
      end
    end

    class InvalidConfigYaml < Error
      def code
        36
      end
    end

    # The syntax of the "manager" configuration in the sphere.yml file is invalid.
    class UnknownManagerError < Error
      def code
        57
      end
    end

    class InvalidManagerConfigurationError < Error
      def code
        58
      end
    end

    # Bio setup could not generate a sphere.yml example file
    class ConfigFileNotWritable < Error
      def code
        38
      end
    end

    # The git command to update the biosphere core failed.
    class CouldNotUpdateBiosphere < Error
      def code
        40
      end
    end

    # Cannot update or activate a sphere that does not exist.
    class SphereNotFound < Error
      def code
        42
      end
    end

  end
end
