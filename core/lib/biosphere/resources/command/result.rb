module Biosphere
  module Resources
    class Command
      class Result

        attr_accessor :stdout, :stderr, :raw_status, :command

        def success?
          raw_status ? raw_status.success? : false
        end

        # Returns an Integer equal or greater than -1
        #
        def status
         raw_status ? raw_status.exitstatus : -1
        end

        def to_s
          "#<Biosphere::Command::Result command=#{command.inspect} status=#{status.inspect} stdout.size=#{stdout.size.inspect}, stderr.size=#{stderr.size.inspect}>"
        end

      end
    end
  end
end
