require 'biosphere/log'
require 'pathname'

module Biosphere
  module Resources
    module File
      extend self

      def write(path, content)
        ::File.open(path, 'w') { |file| file.write content }
      end

    end
  end
end