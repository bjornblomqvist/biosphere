require 'biosphere/log'
require 'pathname'

module Biosphere
  module Resources
    class Path

      attr_reader :path

      # Convenience wrapper
      def self.create(*args)
        new(*args).create
      end

      # Convenience wrapper
      def self.delete(*args)
        new(*args).delete
      end

      def initialize(path)
        @path = Pathname.new path.to_s
      end

      def create
        create! unless exists?
        self
      end

      def delete
        delete! if exists?
        self
      end

      def exists?
        path.exist?
      end

      def join(subpath)
        result = self.class.new path.join(subpath)
      end

      def to_s
        path.to_s
      end

      private

      def create!
        raise NotImplementedError
      end

      def delete!
        raise NotImplementedError
      end

    end
  end
end
