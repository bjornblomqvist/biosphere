require 'biosphere/vendor/string_inquirer'

module Biosphere
  module Runtime

    def self.env
      StringInquirer.new(@env.to_s || 'production')
    end

    def self.env=(environment)
      @env = environment
    end

    def self.privileged?
      Process.uid == 0
    end

    def self.debug_mode?
      command_line_arguments.delete '--debug'
    end

    def self.help_mode?
      command_line_arguments.delete '--help'
    end

    def self.version_mode?
      command_line_arguments.delete('--version') || command_line_arguments.delete('-v')
    end

    def self.arguments
      command_line_arguments - %w(--debug --help --version -v)
    end

    def self.command_line_arguments
      ARGV.dup
    end

  end
end
