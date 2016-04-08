require 'biosphere/log'

class ErrorCodeAnalyizer
  extend self

  class ErrorCodesAssignmentError < Error
    def code() 255 end
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
