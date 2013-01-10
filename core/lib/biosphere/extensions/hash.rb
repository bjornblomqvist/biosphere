module Biosphere
  module Extensions
    module HashExtensions

      def flatten_keys
        result = {}
        flatten_keys_of(self) do |key, value|
          result[key.to_s] = value
        end
        result
      end

      def update_from_flattened_key!(flat_key, value)
        # TODO
      end

      private

      def flatten_keys_of(hash, prev_key=nil, &block)
        hash.each_pair do |key, value|
          curr_key = [prev_key, key].compact.join('.').to_sym
          yield curr_key, value
          flatten_keys_of(value, escape, curr_key, &block) if value.is_a?(Hash)
        end
      end

    end
  end
end

class Hash
  include Biosphere::Extensions::HashExtensions
end