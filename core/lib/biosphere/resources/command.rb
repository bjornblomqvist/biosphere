require 'biosphere/log'
require 'biosphere/runtime'
require 'biosphere/vendor/open4'
require 'biosphere/resources/command/result'

module Biosphere
  module Resources
    class Command

      attr_reader :working_directory, :executable, :show_output, :indent

      # Convenience wrapper
      def self.call(*args)
        self.new(*args).call
      end

      def initialize(working_directory: '/tmp', executable: 'whoami', arguments: [], env_vars: {}, show_output: false, indent: 4)
        @working_directory = working_directory
        @executable        = executable
        @arguments         = arguments
        @env_vars          = env_vars
        @show_output       = show_output
        @indent            = indent.to_i
      end

      def to_s
        command
      end

      def env_vars
        result = []
        @env_vars.each do |key, value|
          result << %{#{key.to_s.upcase}="#{value.to_s.gsub('"', '\"')}"}
        end
        result.empty? ? nil : result.join(' ')
      end

      def arguments
        @arguments.empty? ? nil : @arguments
      end

      def command
        [env_vars, executable, arguments].compact.join(' ')
      end

      def indentation
        ' ' * indent
      end

      def ensure_in_working_directory
        return unless working_directory
        Log.debug { "Switching working directory to: #{working_directory}" }
        Dir.chdir working_directory
      end

      def call
        ensure_in_working_directory
        result = Result.new
        result.command = command # For later inspection
        stdout_lines = []
        stderr_lines = []
        Log.debug { "Running command: #{command}" }

        status = Open4::popen4(command) do |pid, stdin, stdout, stderr|
          Log.debug { "Command runs with PID #{pid}" }
          stdout.sync = true
          stderr.sync = true

          out = Thread.new do
            while stdout_line = stdout.gets
              if Runtime.debug_mode?
                Log.debug { "  STDOUT: #{stdout_line}" }
              elsif show_output
                Log.info indentation + stdout_line.strip.faint
              end
              stdout_lines << stdout_line
            end
          end

          err = Thread.new do
            while stderr_line = stderr.gets
              if Runtime.debug_mode?
                Log.debug { "  STDERR: #{stderr_line}" }
              elsif show_output
                Log.info indentation + stderr_line.strip.faint
              end
              stderr_lines << stderr_line
            end
          end

          out.join
          err.join
        end
        result.stdout = stdout_lines.join("\n")
        result.stderr = stderr_lines.join("\n")
        result.raw_status = status
        Log.debug { "Command exited with status #{result.raw_status}" }
        result

      rescue Errno::ENOENT
        Log.error { "Command not found: #{command}" }
        result
      end

    end
  end
end
