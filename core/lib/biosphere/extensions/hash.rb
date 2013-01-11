module Biosphere
  module Extensions
    module HashExtensions

      def flatten_keys!
        replace flatten_keys
      end

      def flatten_keys(new_hash={}, keys=nil)
        self.each do |key, value|
          keys2 = keys ? "#{keys}.#{key}" : key.to_s
          if value.is_a?(Hash)
            value.flatten_keys(new_hash, keys2)
          else
            new_hash[keys2] = value
          end
        end
        new_hash
      end

      def merge_flat_key!(flat_key, value)
        replace merge_flat_key(flat_key, value, self)
      end

      def merge_flat_key(flat_key, value, new_hash=self)
        keys = flat_key.to_s.split('.')
        next_keys = keys[1..-1].join('.')
        puts "Entering with #{new_hash} and keys #{flat_key}"
        if keys.size == 1
          key = keys.first.to_s
          new_hash[key] = value
        else
          new_hash[keys.first] = {} unless new_hash[keys.first]
          new_hash.merge merge_flat_key(next_keys, value, new_hash[keys.first])
        end
        new_hash
      end

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

    end
  end
end

class Hash
  include Biosphere::Extensions::HashExtensions
end