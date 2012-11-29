module Biosphere
  module Runtime
    extend self

    def privileged?
      Process.uid == 0
    end

    def debug_mode?
      parse
      @debug_mode
    end

    def silent_mode?
      parse
      @silent_mode
    end

    def batch_mode?
      parse
      @batch_mode
    end

    def arguments
      @arguments ||= ARGV.dup
    end

    private

    def parse
      @debug_mode  ||= !!arguments.delete('--debug')
      @silent_mode ||= !!arguments.delete('--silent')
      @batch_mode  ||= !!arguments.delete('--batch')
    end

  end
end