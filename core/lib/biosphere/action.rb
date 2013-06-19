require 'biosphere/container'
require 'biosphere/log'

module Biosphere
  module Action
    extend Container
    extend self

    def initialize(args)
      @args = args
    end

    def perform(args = [])
      name = args.shift || 'help'
      perform! name, args
    end

    private

    def perform!(name, args)
      if action = find(name)
        Log.debug "Loading action #{name.inspect} with arguments: #{args.join(' ')}"
        action.new(args).perform
      else
        Log.separator
        Log.error "  Unknown action: #{name}".red
        Log.error "  Try ".cyan + "bio help".bold
        Log.separator
      end
    end

  end
end
