require 'biosphere/log'
require 'pathname'

module Biosphere
  module Resources
    module Directory
      extend self

      def ensure(path)
        path = Pathname.new path
        unless path.exist?
          Log.debug "Creating directory #{path}"
          path.mkdir
        end
        path
      end

    end
  end
end