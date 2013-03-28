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
        @path = Pathname.new path
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
