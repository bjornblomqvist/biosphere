require 'biosphere/log'
require 'open3'

module Biosphere
  module Resources
    class Command

      class Result
        attr_accessor :stdout, :stderr, :raw_status, :command

        def success?
          self.raw_status.success?
        end

        def status
          self.raw_status.exitstatus
        end

        def to_s
          "#<Biosphere::Command::Result command=#{command.inspect} status=#{status.inspect} stdout.size=#{stdout.size.inspect}, stderr.size=#{stderr.size.inspect}>"
        end
      end

      attr_reader :executable, :arguments

      # Convenience wrapper
      def self.run(*args)
        self.new(*args).run
      end

      def initialize(executable, arguments=[])
        @executable = executable
        @arguments = arguments
      end

      def command
        [executable, arguments].join(' ')
      end

      def run
        result = Result.new
        result.command = command # For later inspection
        stdout_lines = []
        stderr_lines = []
        Log.debug "Running command: #{command}"
        Open3.popen3(command) do |_, stdout, stderr|
          stdout.sync = true
          stderr.sync = true
          while (stdout_line = stdout.gets) || (stderr_line = stderr.gets)
            if stdout_line
              Log.debug "  STDOUT: #{stdout_line}"
              stdout_lines << stdout_line
            end
            if stderr_line
              Log.debug "  STDERR: #{stderr_line}"
              stderr_lines << stderr_line
            end
          end
        end
        result.stdout = stdout_lines.join("\n")
        result.stderr = stderr_lines.join("\n")
        result.raw_status = $?
        result
      end

    end
  end
end