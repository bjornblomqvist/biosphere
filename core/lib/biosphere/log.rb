module Biosphere
  module Log

    def self.debug(&block)
      logger.debug(&block)
    end

    def self.info(&block)
      logger.info(&block)
    end

    def self.error(&block)
      logger.error(&block)
    end

    private

    def self.logger
      @logger ||= Logger.new
    end

  end
end
