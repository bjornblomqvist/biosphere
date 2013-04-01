module Biosphere
  module Runtime
    extend self

    def privileged?
      Process.uid == 0
    end

    def debug_mode?
      load unless loaded?
      @debug_mode
    end

    def silent_mode?
      load unless loaded?
      @silent_mode
    end

    def batch_mode?
      load unless loaded?
      @batch_mode
    end

    def help_mode?
      load unless loaded?
      @help_mode
    end

    def arguments
      return @arguments if @arguments
      @arguments = ARGV.dup
      load
      @arguments
    end

    private

    # Lazy loading
    def load
      @debug_mode  = !!arguments.delete('--debug')
      @silent_mode = !!arguments.delete('--silent')
      @batch_mode  = !!arguments.delete('--batch')
      @help_mode   = !!arguments.delete('--help')
      arguments.freeze
    end

    def loaded?
      @arguments
    end

    # Useful for testing
    def reset!
      @arguments = nil
      load
    end

  end
end
