require 'biosphere/extensions/string'
require 'biosphere/runtime'

module Biosphere
  class Logger

    def debug(&block)
      # puts block.call
      return unless Runtime.debug_mode?
      say :debug, &block
    end

    def info(&block)
      # puts block.call
      say :info, &block
    end

    def warn(&block)
      say :warn, &block
    end

    def error(&block)
      say :error, &block
    end

    def separator
      output
    end

    private

    def say(level)
      if Runtime.debug_mode?
        output prefixed(level, yield)
      else
        output yield
      end
    end

    def prefixed(level, message)
      message.insert 0, prefix_for(level)
    end

    def prefix_for(level)
      case level
      when :debug then 'DEBUG: '.blue
      when :info  then 'INFO : '
      when :warn  then 'WARN : '.yellow
      when :error then 'ERROR: '.red
      end
    end

    def output(message = nil)
      return if Runtime.env.test?
      puts message
    end

  end
end
