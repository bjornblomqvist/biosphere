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
  class Augmentator
    attr_reader :spheres

    def initialize(options={})
      @spheres = options[:spheres] || []
    end

    def perform
      gather
      augment gathered_augmentations
    end

    def implode
      augmentations = {}
      valid_augmentation_identifiers.each do |identifier|
        augmentations[identifier] = ''
      end
      augment augmentations
    end

    private

    def gather
      sphere_augmentations.each do |identifier, contents|
        destination = augmentations_path.join(identifier.to_s)
        if destination.parent.writable?
          if contents.empty?
            if destination.exist?
              Log.debug "Removing #{destination} because there are no augmentations for it by any sphere..."
              Resources::File.delete destination
            end
          else
            Log.debug "Writing gathered #{identifier} augmentations to #{destination}..."
            Resources::File.write(destination, contents.join("\n\n"))
          end
        else
          message = "Cannot write to #{destination}"
          Log.error message.red
          raise Errors::CannotWriteGatheredAugmentations, message
        end
      end
    end

    def augment(augmentations)
      augmentations.each do |identifier, content|
        next unless destination = augmentation_destination_path(identifier)
        if destination.exist?
          if destination.writable?
            Log.debug "Augmenting #{destination}..."
            Resources::File.augment destination, content
          else
            Log.info "Skipping augmentation of #{destination} because the file is not writable."
          end
        else
          Log.info "Skipping augmentation of #{destination} because the file does not exist."
        end
      end
      # Going to augment files outside of biosphere sandbox here...
    end

    def gathered_augmentations
      result = {}
      valid_augmentation_identifiers.each do |identifier|
        path = augmentations_path.join(identifier.to_s)
        next unless path.exist?
        result[identifier] = path.read
      end
      result
    end

    def sphere_augmentations
      result = {}
      spheres.each do |sphere|
        valid_augmentation_identifiers.each do |identifier|
          result[identifier] = [] unless result[identifier]
          augmentation = sphere.augmentation(identifier)
          if augmentation
            Log.debug "Gathering #{identifier} augmentations from sphere #{sphere.name}..."
            augmentation = "# SPHERE #{sphere.name.upcase}\n\n#{augmentation}"
            if augmentation_prominence?(identifier) == :earlier
              result[identifier].push augmentation
            else
              result[identifier].unshift augmentation
            end
          else
            Log.debug "No #{identifier} augmentations to gather from sphere #{sphere.name}..."
          end
        end
      end
      result
    end

    def augmentation_prominence?(identifier)
      case identifier
      when :ssh_config then :earlier # Earlier things in ~/.ssh/config override later things
      else                  :later   # Later things in e.g. ~/.bash_profile override earlier things
      end
    end

    def augmentation_destination_path(identifier)
      result = case identifier
      when :ssh_config   then '~/.ssh/config'
      end
      result ? Pathname.new(result).expand_path : nil
    end

    def valid_augmentation_identifiers
      [:bash_profile, :zshenv, :ssh_config]
    end

    def augmentations_path
      Pathname.new BIOSPHERE_AUGMENTATIONS_PATH
    end

  end
end