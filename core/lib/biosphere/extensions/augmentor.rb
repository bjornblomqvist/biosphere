require 'pathname'

module Biosphere
  module Extensions
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
      end

      class Result
        attr_reader :status

        def initialize(options={})
          @success = options[:success]
          @status = options[:status]
        end

        def success?
          !!@success
        end
      end

      attr_reader :file, :content

      def initialize(options={})
        @file = Pathname.new(options[:file]).expand_path
        @content = options[:content]
      end

      def perform
        content ? add_or_update : implode
      end

      private

      def add_or_update
        return result(false, :file_not_found) unless exists?
        return result(false, :file_not_readable) unless readable?
        if augmented?
          replace snippet.regexp, snippet.to_s
        else
          append snippet.to_s
        end
      end

      def implode
        return result(true, :file_not_found) unless exists?
        return result(false, :file_not_readable) unless readable?
        return result(true, :file_not_augmented) unless augmented?
        replace snippet.regexp
      end

      def replace(this, that='')
        return result(false, :file_not_found) unless exists?
        return result(false, :file_not_readable) unless readable?
        current_content = file.read
        current_digest = digest(current_content)
        new_content = current_content.sub(this, that.to_s)
        new_digest = digest(new_content)
        if current_digest == new_digest
          result true, :already_up_to_date
        else
          return result(false, :file_not_writable) unless writable?
          write new_content
          result true, :content_updated
        end
      end

      def append(this)
        return result(false, :file_not_found) unless exists?
        return result(false, :file_not_readable) unless readable?
        return result(false, :file_not_writable) unless writable?
        new_content = file.read.chomp + "\n\n" + this.to_s + "\n"
        write new_content
        result true, :content_appended
      end

      def exists?
        file.exist?
      end

      def readable?
        file.readable?
      end

      def writable?
        file.writable?
      end

      def augmented?
        file.read =~ snippet.regexp
      end

      def write(content)
        file.open('w') { |f| f.write(content) }
      end

      def digest(content)
        Digest::MD5::hexdigest(content)
      end

      def result(success, status)
        Result.new :success => success, :status => status
      end

      def snippet
        Snippet.new content
      end

    end
  end
end
