require 'biosphere/extensions/string'
require 'biosphere/runtime'
require 'singleton'

module Biosphere
  class Logger

    def debug(message)
      say message, :debug if debug_mode?
    end

    def info(message)
      say message, :info unless batch_mode?
    end

    def error(message)
      say message, :error unless batch_mode?
    end

    def batch(message)
      say message, :batch if batch_mode?
    end

    def separator
      say unless batch_mode?
    end

    private

    def debug_mode?
      Runtime.debug_mode?
    end

    def silent_mode?
      Runtime.silent_mode?
    end

    def batch_mode?
      Runtime.batch_mode?
    end

    def say(message = nil, mode = nil)
      message = message.to_s
      message = add_prefix(message, mode)
      output message
    end

    def add_prefix(message, mode)
      return message unless debug_mode?
      prefix = case mode
      when :debug then 'DEBUG: '.blue
      when :info  then 'INFO : '
      when :error then 'ERROR: '.red
      when :batch then 'BATCH: '.cyan
      else             ' '
      end
      message.insert 0, prefix
    end

    def output(message)
      silent_mode? || output!(message)
    end

    def output!(message)
      puts message
    end

  end
end
