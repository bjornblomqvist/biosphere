module Biosphere
  module Extensions
    module HashExtensions

      def deep_stringify_keys
       inject({}) { |result, (key, value)|
         value = value.deep_stringify_keys if value.is_a?(Hash)
         result[(key.to_s rescue key) || key] = value
         result
       }
      end

      def deep_stringify_keys!
       stringify_keys!
       each do |k, v|
         self[k] = self[k].deep_stringify_keys! if self[k].is_a?(Hash)
       end
       self
      end

      def symbolize_keys
        dup.symbolize_keys!
      end

      def symbolize_keys!
        keys.each do |key|
          self[(key.to_sym rescue key) || key] = delete(key)
        end
        self
      end

    end
  end
end

class Hash
  include Biosphere::Extensions::HashExtensions
end
