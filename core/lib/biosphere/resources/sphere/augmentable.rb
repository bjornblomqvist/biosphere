module Biosphere
  module Resources
    class Sphere
      module Augmentable

        def self.included(base)
          base.extend ClassMethods
        end

        module ClassMethods

          def augmentations
            result = {}
            all.select(&:activated?).each do |sphere|
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
            result
          end

          def augmentation_identifiers
            [:bash_profile, :zshenv, :ssh_config]
          end

          def augmentation_prominence?(identifier)
            case identifier
            when :ssh_config then :earlier # Earlier things in ~/.ssh/config override later things
            else                  :later   # Later things in e.g. ~/.bash_profile override earlier things
            end
          end

        end

        def augmentations_path
          Directory.create path.join('augmentations')
        end

        def augmentation(identifier)
          path = augmentations_path.join(identifier.to_s)
          path.exist? ? path.read : nil
        end

      end
    end
  end
end