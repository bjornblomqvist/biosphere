require 'ostruct'
require 'biosphere/extensions/to_json'

module Biosphere
  module Extensions
    module OpenStructExtensions

      def to_h
        @table.dup
      end

      def to_json
        to_h.to_json
      end

    end
  end
end

class OpenStruct
  include Biosphere::Extensions::OpenStructExtensions
end