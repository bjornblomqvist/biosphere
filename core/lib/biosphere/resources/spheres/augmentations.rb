module Biosphere
  module Resources
    module Spheres
      module Augmentations

        def self.augmentations
          result = {}
          Spheres.all.select(&:activated?).each do |sphere|
            augmentation_identifiers.each do |identifier|
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
          result.each { |key, value| result[key] = value.join("\n\n") }
          result
        end

        def self.augmentation_identifiers
          [:shell, :bash_profile, :zshenv, :ssh_config]
        end

        def self.augmentation_prominence?(identifier)
          case identifier
          when :ssh_config then :earlier # Earlier things in ~/.ssh/config override later things
          else                  :later   # Later things in e.g. ~/.bash_profile override earlier things
          end
        end

      end
    end
  end
end
