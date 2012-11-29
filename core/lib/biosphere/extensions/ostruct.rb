require 'ostruct'

module Biosphere
  module Extensions
    module OpenStructExtensions

      def to_h
        @table.dup
      end

    end
  end
end

class OpenStruct
  include Biosphere::Extensions::OpenStructExtensions
end