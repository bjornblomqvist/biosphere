module Biosphere
  module Runtime
    extend self

    def load
      @@debug_mode  ||= !!arguments.delete('--debug')
      @@silent_mode ||= !!arguments.delete('--silent')
      @@batch_mode  ||= !!arguments.delete('--batch')
      @@help_mode   ||= !!arguments.delete('--help')
      @@arguments.freeze
    end

    def privileged?
      Process.uid == 0
    end

    def debug_mode?
      @@debug_mode
    end

    def silent_mode?
      @@silent_mode
    end

    def batch_mode?
      @@batch_mode
    end

    def help_mode?
      @@help_mode
    end

    def arguments
      @@arguments ||= ARGV.dup
    end

  end
end

Biosphere::Runtime.load