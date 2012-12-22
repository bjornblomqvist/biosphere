require 'biosphere/container'
require 'biosphere/log'

module Biosphere
  class Action < Container

    def self.perform(args=[])
      name = args.shift || 'help'
      perform! name, args
    end

    private

    def self.perform!(name, args)
      if action = find(name)
        Log.debug "Loading action #{name.inspect} with arguments: #{args.join(' ')}"
        action.new.perform args
      else
        Log.separator
        Log.error "  Unknown action: #{name}".red
        Log.error "  Try ".cyan + "bio help".bold
        Log.separator
      end
    end

  end
end