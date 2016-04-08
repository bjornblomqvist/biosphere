require 'ostruct'
require 'biosphere/extensions/hash'

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
        @table.deep_stringify_keys.dup
      end

    end
  end
end

class OpenStruct
  include Biosphere::Extensions::OpenStructExtensions
end