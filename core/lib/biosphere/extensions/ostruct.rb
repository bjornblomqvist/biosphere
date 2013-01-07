require 'ostruct'
require 'biosphere/extensions/json'

module Biosphere
  module Extensions
    module OpenStructExtensions

      def empty?
        @table.empty?
      end

      def any?
        @table.any?
      end

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