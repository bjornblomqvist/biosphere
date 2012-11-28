require 'biosphere/log'
require 'pathname'

module Biosphere
  module Resources
    module Filesystem
      extend self

      def ensure_directory(path)
        path = Pathname.new path
        unless path.exist?
          Log.debug "Creating directory #{path}"
          path.mkdir
        end
        path
      end

      def write_to_file(path, content)
        File.open(path, 'w') { |file| file.write content }
      end

    end
  end
end