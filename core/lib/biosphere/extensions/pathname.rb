require 'biosphere/tools/augmentor'
require 'digest/md5'

module Biosphere
  module Extensions
    module PathnameExtensions

      module ClassMethods
        def home_path
          new(@home_path || ENV['HOME'])
        end

        def home_path=(path)
          @home_path = path
        end
      end

      def unexpand_path
        return self unless to_s =~ /^#{self.class.home_path}/
        self.class.new('$HOME').join relative_path_from(self.class.home_path)
      end

      def augment(content = nil)
        Tools::Augmentor.new(file: self, content: content).perform
      end

    end
  end
end

class Pathname
  include Biosphere::Extensions::PathnameExtensions
  extend Biosphere::Extensions::PathnameExtensions::ClassMethods
end
