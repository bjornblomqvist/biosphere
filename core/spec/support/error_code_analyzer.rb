require 'biosphere/errors'

class ErrorCodeAnalyzer

  def self.validate!
    return if valid?
    duplicate_codes = codes.select { |code| codes.rindex(code) != codes.index(code) }
    conflicting_instances = instances.select { |instance| duplicate_codes.include?(instance.code) }
    conflicts = conflicting_instances.map { |instance| "#{instance.class} (#{instance.code})" }
    raise ErrorCodesAssignmentError.new, "There are multiple Error Classes with the same error codes: #{conflicts.join(', ')}"
  end

  def self.valid?
    codes.size == codes.uniq.size
  end

  private

  def self.codes
    instances.map &:code
  end

  def self.instances
    names.map do |name|
      const_get(name).new
    end
  end

  def self.names
    constants - %w{ Error }
  end

end
