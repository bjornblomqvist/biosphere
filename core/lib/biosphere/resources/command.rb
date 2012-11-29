require 'biosphere/log'
require 'biosphere/runtime'
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

      attr_reader :executable, :arguments, :show_output

      # Convenience wrapper
      def self.run(*args)
        self.new(*args).run
      end

      def initialize(options={})
        @executable = options[:executable] || 'whoami'
        @arguments = options[:arguments] || []
        @env_vars = options[:env_vars] || {}
        @show_output = options[:show_output] || false
      end

      def to_s
        command
      end

      def env_vars
        result = []
        @env_vars.each do |key, value|
          result << %{#{key.to_s.upcase}="#{value.to_s.gsub('"', '\"')}"}
        end
        result.join(' ')
      end

      def command
        [env_vars, executable, arguments].join(' ')
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

          out = Thread.new do
            while stdout_line = stdout.gets
              if Runtime.debug_mode?
                Log.debug "  STDOUT: #{stdout_line}"
              elsif show_output
                Log.info stdout_line
              end
              stdout_lines << stdout_line
            end
          end

          err = Thread.new do
            while stderr_line = stderr.gets
              if Runtime.debug_mode?
                Log.debug "  STDERR: #{stderr_line}"
              elsif show_output
                Log.info stderr_line
              end
              stderr_lines << stderr_line
            end
          end

          out.join
          err.join
        end
        result.stdout = stdout_lines.join("\n")
        result.stderr = stderr_lines.join("\n")
        result.raw_status = $?
        result
      end

    end
  end
end