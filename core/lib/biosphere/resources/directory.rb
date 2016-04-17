require 'biosphere/resources/path'

module Biosphere
  module Resources
    class Directory < Path

      # Convenience wrapper
      def self.clear(*args)
        new(*args).clear
      end

      def clear
        clear! unless files.empty?
        self
      end

      private

      def create!
        Log.debug { "Creating directory #{path}" }
        path.mkpath
      end

      def clear!
        Log.debug { "Deleting all files in directory #{path}" }

        files.each do |file_path|
          Log.debug { "Deleting #{file_path}" }
          file_path.delete
        end
      end

      def files
        path.children.select(&:file?)
      end

    end
  end
end
