require 'optparse'

module Biosphere
  module Extensions
    class OptionParser < ::OptionParser

      def valid_options(&block)
        parser.on("--verbose", "Run verbosely") do |v|
          options[:verbose] = v
        end
      end

      def options
        @options ||= begin
          options = {}
          OptionParser.new do |parser|

            #opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
            #  options[:verbose] = v
            #end

          end.order(ARGV)
        end
      end

    end
  end
end