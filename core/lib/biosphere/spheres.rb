require 'biosphere/resources/sphere'

module Biosphere
  module Spheres

    def self.all
      paths.sort.map { |sphere_path| Resources::Sphere.new(sphere_path.basename) }
    end

    def self.activated
      all.select(&:activated?)
    end

    def self.find(name)
      all.detect { |sphere| sphere.name == name }
    end

    def self.paths
      Pathname.glob Paths.spheres.join('*')
    end

  end
end
