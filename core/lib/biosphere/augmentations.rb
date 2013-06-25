require 'biosphere/resources/file'
require 'biosphere/error'
require 'pathname'

module Biosphere
  module Errors
    class CannotWriteGatheredAugmentations < Error
      def code() 100 end
    end
  end
end

module Biosphere
  # ErrorCodes: 100-110
  class Augmentations

    attr_reader :spheres

    def initialize(options={})
      @spheres = options[:spheres] || []
    end

    def self.perform(*args)
      new(*args).perform
    end

    def self.implode(*args)
      new(*args).implode
    end

    def perform
      update
      apply
    end

    def implode
      clear
      Resources::Sphere.augmentation_identifiers.each do |identifier|
        destination = destination_path(identifier)
        next unless destination && destination.exist?
        Log.debug "Imploding augmentation for #{destination}"
        Resources::File.augment destination
      end
    end

    private

    def update
      clear
      harvest
    end

    def clear
      Log.debug "Clearing cached augmentations..."
      Resources::Sphere.augmentation_identifiers.each do |identifier|
        Resources::File.delete Paths.augmentations.join(identifier.to_s)
      end
    end

    def harvest
      Resources::Sphere.augmentations.each do |identifier, content|
        path = augmentations_path.join(identifier.to_s)
        if content.empty?
          Log.debug "Removing cached augmentation for #{identifier}..."
          Resources::File.delete path
        else
          Log.debug "Caching augmentation for #{identifier}..."
          Resources::File.write path, content
        end
      end
    end

    def apply
      Resources::Sphere.augmentation_identifiers.each do |identifier|
        source = augmentations_path.join(identifier.to_s)
        next unless source.file?
        next unless destination = destination_path(identifier)
        Resources::File.augment destination, source.read
      end
    end

    def destination_path(identifier)
      result = case identifier
      when :ssh_config   then '~/.ssh/config'
      end
      result ? Pathname.new(result).expand_path : nil
    end

    def augmentations_path
      Pathname.new BIOSPHERE_AUGMENTATIONS_PATH
    end

  end
end