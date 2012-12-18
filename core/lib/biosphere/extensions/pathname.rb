require 'digest/md5'

module Biosphere
  module Extensions
    module PathnameExtensions

      # Returns true if the target file was modified at all, false if not.
      # Raises an exception if the file could not be augmented as it should.
      #
      def augment(options={})
        raise "Cannot augment file #{self}, because it doesn't exist." unless self.exist?
        raise "Cannot augment file #{self}, because it is a directory." if self.directory?
        raise "Cannot augment file #{self}, because of missing permissions." unless self.writable?
        start_tag = options[:start_tag] || '### BIOSPHERE MANAGED START ###'
        end_tag = options[:end_tag] || '### BIOSPHERE MANAGED STOP ###'
        implode = !!options[:implode]
        if options[:augmentation_file] && augmentation_file = Pathname.new(options[:augmentation_file])
          raise "Cannot read augmentation_file #{augmentation_file}, because it doesn't exist." unless augmentation_file.exit?
          raise "Cannot read augmentation_file #{augmentation_file}, because of missing permissions." unless augmentation_file.readable?
          augmentation = augmentation_file.read
        else
          augmentation = (options[:augmentation] || '').to_s
        end
        augmentation = implode ? '' : start_tag + "\n" + augmentation + "\n" + end_tag
        current_content = self.read
        current_digest = Digest::MD5::hexdigest(current_content)
        if current_content.include?(start_tag)
          new_content = current_content.gsub(/#{start_tag}(.*)#{end_tag}/m, augmentation)
        else
          new_content = "#{current_content}\n#{augmentation}\n"
        end
        self.open('w') { |f| f.write(new_content) }
        current_digest != Digest::MD5::hexdigest(self.read)
      end

    end
  end
end

class Pathname
  include Biosphere::Extensions::PathnameExtensions
end