require 'biosphere/extensions/augmentor'
require 'digest/md5'

module Biosphere
  module Extensions
    module PathnameExtensions

      def unexpand_path
        home_path = self.class.new ENV['HOME']
        self.class.new('~').join relative_path_from(home_path)
      end

      def augment(content)
        Augmentor.new(:file => self, :content => content).perform
      end

    end
  end
end

class Pathname
  include Biosphere::Extensions::PathnameExtensions
end