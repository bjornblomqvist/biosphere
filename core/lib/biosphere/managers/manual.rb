require 'biosphere/log'
require 'biosphere/managers/default'

module Biosphere
  module Managers
    class Manual < Default

    end
  end
end

Biosphere::Manager.register Biosphere::Managers::Manual.new