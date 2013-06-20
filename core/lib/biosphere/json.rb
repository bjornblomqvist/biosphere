require 'biosphere/vendor/okjson'

module Biosphere
  module JSON
    def self.load(object)
      ::OkJson.decode object
    end

    def self.dump(object)
      ::OkJson.encode object
    end
  end
end
