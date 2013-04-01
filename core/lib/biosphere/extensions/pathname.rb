require 'biosphere/tools/augmentor'
require 'digest/md5'

module Biosphere
  module Extensions
    module PathnameExtensions

      module ClassMethods
        def home_path
          new home_env
        end

        def home_env
          ENV['HOME']
        end
      end

      def unexpand_path
        return self unless self.to_s =~ /^#{self.class.home_path}/
        self.class.new('~').join relative_path_from(self.class.home_path)
      end

      def augment(content = nil)
        Tools::Augmentor.new(:file => self, :content => content).perform
      end

    end
  end
end

class Pathname
  include Biosphere::Extensions::PathnameExtensions
  extend Biosphere::Extensions::PathnameExtensions::ClassMethods
end
