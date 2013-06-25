module Biosphere
  module Resources
    class Sphere
      module Activatable

        def activated?
          activated_file_path.exist?
        end

        def activate!(index = 0)
          Resources::File.write activated_file_path, index
        end

        def deactivate!
          Resources::File.delete activated_file_path
        end

        def activation_order
          return 0 unless activated?
          activated_file_path.read.to_i
        end

        private

        def activated_file_path
          path.join(activated_file_name)
        end

        def activated_file_name
          'active'
        end

      end
    end
  end
end