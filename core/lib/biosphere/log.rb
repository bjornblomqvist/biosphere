require 'biosphere/logger'

module Biosphere
  module Log
    extend self

    def method_missing(method, *args)
      logger.send method, *args
    end

    private

    def logger
      @logger ||= Logger.new
    end

  end
end
