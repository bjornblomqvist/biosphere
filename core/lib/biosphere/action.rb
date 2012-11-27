require 'biosphere/container'
require 'biosphere/log'

module Biosphere
  class Action < Container

    def self.perform(name)
      name = 'help' unless name
      if action = store[name]
        action.perform
      else
        Log.separator
        Log.error "  Unknown action: #{name}".red
        Log.error "  Try ".cyan + "bio help".bold
        Log.separator
      end
    end

  end
end