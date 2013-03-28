require 'biosphere/resources/path'

module Biosphere
  module Resources
    class File < Path

      # Convenience wrapper
      def self.write(path, content = nil)
        new(path).write content
      end

      # Convenience wrapper
      def self.augment(path, *args)
        new(path).augment *args
      end

      def write(content = nil)
        path.open('w') { |io| io.write content }
      end

      def augment(*args)
        path.augment(*args)
      end

      private

      def create!
        Log.debug "Creating file #{path}"
        path.open('a')
      end

      def delete!
        Log.debug "Deleting file #{path}"
        path.delete
      end

    end
  end
end