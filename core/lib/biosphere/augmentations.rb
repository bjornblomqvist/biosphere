require 'biosphere/resources/file'
require 'biosphere/errors'
require 'biosphere/paths'
require 'pathname'

module Biosphere
  class Augmentations

    def initialize(sphere: nil)
      @sphere = sphere
    end

    # Convenience Wrapper
    def self.implode
      new.implode
    end

    def call
      clear
      clear_ssh_config
      harvest
      harvest_ssh_config
    end

    #def implode
    #  clear
    #  Resources::Sphere.augmentation_identifiers.each do |identifier|
    #    destination = destination_path(identifier)
    #    next unless destination && destination.exist?
    #    Log.debug { "Imploding augmentation for #{destination}" }
    #    Resources::File.augment destination
    #  end
    #end

    private

    attr_reader :sphere

    def clear
      Log.debug { 'Clearing cached augmentations...' }
      Resources::Directory.new(Paths.augmentations).clear
    end

    def clear_ssh_config
      Paths.ssh_config.augment
    end

    def harvest
      Log.debug { "Applying augmentations of sphere #{sphere.name.inspect}..." }

      sphere.augmentations_path.children.select(&:file?).each do |child|
        target = Paths.augmentations.join(child.basename)
        Resources::File.write target, child.read
      end
    end

    def harvest_ssh_config
      unless Paths.ssh_config_augmentation.exist?
        Log.debug { "No need to apply a SSH config because there is no #{Paths.ssh_config_augmentation}..." }
        return
      end

      Log.debug { "Applying SSH config of sphere #{sphere.name.inspect} (outside of the sandbox!)..." }
      ensure_ssh_config_directory
      ensure_ssh_config_file

      augmentation = Paths.ssh_config.augment Paths.ssh_config_augmentation.read
      Log.debug { augmentation.inspect }
    end

    def ensure_ssh_config_directory
      return if Paths.ssh_config.dirname.exist?

      Log.info { "  Allow me to create your ssh directory at #{Paths.ssh_config.dirname} with permissions 0700...".yellow }
      Resources::Directory.create Paths.ssh_config.dirname
      Paths.ssh_config.dirname.chmod 0700
    end

    def ensure_ssh_config_file
      return if Paths.ssh_config.exist?

      Log.info { "  Allow me to create your ssh config file at #{Paths.ssh_config} with permissions 0600...".yellow }
      Resources::File.create Paths.ssh_config
      Paths.ssh_config.chmod 0600
    end

  end
end
