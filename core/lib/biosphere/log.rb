require 'biosphere/extensions/string'
require 'biosphere/runtime'
require 'singleton'

module Biosphere
  class Log
    include Singleton

    def self.debug(*args)
      instance.debug(*args)
    end

    def self.info(*args)
      instance.info(*args)
    end

    def self.error(*args)
      instance.error(*args)
    end

    def self.batch(*args)
      instance.batch(*args)
    end

    def self.separator(*args)
      instance.separator(*args)
    end

    def debug(message)
      say(message, :debug) if debug_mode
    end

    def info(message)
      say(message, :info) unless batch_mode
    end

    def error(message)
      say(message, :error) unless batch_mode
    end

    def batch(message)
      say(message, :batch) if batch_mode
    end

    def separator
      say('') unless batch_mode
    end

    private

    def debug_mode
      Runtime.debug_mode?
    end

    def silent_mode
      Runtime.silent_mode?
    end

    def batch_mode
      Runtime.batch_mode?
    end

    def say(message, mode=nil)
      if debug_mode
        prefix = case mode
        when :debug then 'DEBUG: '.blue
        when :info  then 'INFO : '
        when :error then 'ERROR: '.red
        when :batch then 'BATCH: '.cyan
        else             ' '
        end
        message.insert 0, prefix
      end
      output message
    end

    def output(message)
      return if silent_mode
      puts message
    end

  end
end