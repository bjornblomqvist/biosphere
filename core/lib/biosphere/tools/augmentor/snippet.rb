module Biosphere
  module Tools
    class Augmentor
      class Snippet

        attr_reader :content, :start_tag, :end_tag

        def initialize(content, options={})
          @content = content
          @start_tag = options[:stat_tag] || '### BIOSPHERE MANAGED START ###'
          @end_tag = options[:end_tag] || '### BIOSPHERE MANAGED STOP ###'
        end

        def to_s
          [start_tag, content, end_tag].compact.join("\n\n")
        end

        def regexp
          /#{start_tag}(.*)#{end_tag}/m
        end

        def removal_regexp
          /#{start_tag}(.*)#{end_tag}\n?/m
        end

      end
    end
  end
end
