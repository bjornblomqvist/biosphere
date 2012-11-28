module Biosphere
  module Runtime
    extend self

    def privileged?
      Process.uid == 0
    end

    def debug_mode?
      ARGV.include? '--debug'
    end

    def silent_mode?
      ARGV.include? '--silent'
    end

    def batch_mode?
      ARGV.include? '--batch'
    end

  end
end