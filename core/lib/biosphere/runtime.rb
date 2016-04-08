require 'biosphere/vendor/string_inquirer'

module Biosphere
  module Runtime

    def self.env=(environment)
      @env = environment
    end

    def self.env
      StringInquirer.new(@env.to_s || 'production')
    end

    def self.privileged?
      Process.uid == 0
    end

    def self.debug_mode?
      load unless loaded?
      @debug_mode
    end

    def self.help_mode?
      load unless loaded?
      @help_mode
    end

    def self.version_mode?
      load unless loaded?
      @version_mode
    end

    def self.arguments
      load unless loaded?
      @arguments
    end

    def self.load
      @arguments = ARGV.dup
      @debug_mode   = @arguments.delete('--debug')   ? true : false
      @help_mode    = @arguments.delete('--help')    ? true : false
      @version_mode = @arguments.delete('--version') || @arguments.delete('-v') ? true : false
      @arguments.freeze
    end
    private_class_method :load

    def self.loaded?
      @arguments
    end
    private_class_method :loaded?

    # Useful for testing
    def self.reset!
      @arguments = nil
    end
    private_class_method :reset!

  end
end
