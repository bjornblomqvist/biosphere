module Biosphere
  module Resources
    module Spheres

      def self.all
        paths.sort.map { |sphere_path| new(sphere_path.basename) }
      end

      def self.find(name_or_names)
        if name_or_names.is_a?(Array)
          name_or_names.map do |name|
            find name
          end.compact
        else
          all.detect { |sphere| sphere.name == name_or_names }
        end
      end

      def self.paths
        Pathname.glob Paths.spheres.join('*')
      end

    end
  end
end
