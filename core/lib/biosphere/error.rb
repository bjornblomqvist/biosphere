require 'biosphere/log'

module Biosphere
  module Errors
    extend self

    # The Parent of all Biosphere-related errors
    class Error < StandardError

      # 0 = no errors
      # 1 = uncaught, abnormal error
      # 2 or higher = biosphere errors
      def code
        2
      end
    end

    class ErrorCodesAssignmentError < Error
      def code() 255 end
    end

    class InterruptError < Error
      def code() 130 end
    end

    def validate!
      return if valid?
      duplicate_codes = codes.select { |code| codes.rindex(code) != codes.index(code) }
      conflicting_instances = instances.select { |instance| duplicate_codes.include?(instance.code) }
      conflicts = conflicting_instances.map { |instance| "#{instance.class} (#{instance.code})" }
      raise ErrorCodesAssignmentError.new, "There are multiple Error Classes with the same error codes: #{conflicts.join(', ')}"
    end

    def valid?
      codes.size == codes.uniq.size
    end

    private

    def codes
      instances.map &:code
    end

    def instances
      names.map do |name|
        const_get(name).new
      end
    end

    def names
      constants - %w{ Error }
    end
  end
end
