require 'biosphere/logger'

module Biosphere
  module Log

    def self.debug(&block)
      logger.debug(&block)
    end

    def self.info(&block)
      logger.info(&block)
    end

    def self.warn(&block)
      logger.warn(&block)
    end

    def self.error(&block)
      logger.error(&block)
    end

    def self.separator
      logger.separator
    end

    def self.logger
      @logger ||= Logger.new
    end
    private_class_method :logger

  end
end
