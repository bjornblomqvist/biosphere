require 'biosphere/log'
require 'biosphere/extensions/pathname'

module Biosphere
  module Resources
    module File
      extend self

      def write(path, content=nil)
        path = Pathname.new(path)
        path.open('w') { |file| file.write content }
      end

      # Raises if operation not successful.
      def delete(path)
        path = Pathname.new(path)
        if path.exist?
          path.delete
        end
        true
      end

      def augment(path, *args)
        Pathname.new(path).augment(*args)
      end

    end
  end
end