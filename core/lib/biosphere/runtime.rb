require 'biosphere/vendor/string_inquirer'

module Biosphere
  module Runtime
    extend self

    def env=(environment)
      @env = environment
    end

    def env
      StringInquirer.new(@env.to_s || 'production')
    end

    def privileged?
      Process.uid == 0
    end

    def debug_mode?
      load unless loaded?
      @debug_mode
    end

    def help_mode?
      load unless loaded?
      @help_mode
    end

    def arguments
      load unless loaded?
      @arguments
    end

    private

    def load
      @arguments = ARGV.dup
      @debug_mode  = !!@arguments.delete('--debug')
      @help_mode   = !!@arguments.delete('--help')
      @arguments.freeze
    end

    def loaded?
      @arguments
    end

    # Useful for testing
    def reset!
      @arguments = nil
    end

  end
end
