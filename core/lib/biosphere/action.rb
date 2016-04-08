require 'biosphere/log'
require 'biosphere/errors'

module Biosphere
  class Action

    def initialize(args = [])
      @name = args.shift || 'help'
      @arguments = args
    end

    def call
      action ? load : cancel
    end

    private

    attr_reader :name, :arguments

    def load
      Log.debug { "Loading action #{name.inspect} with arguments: #{arguments.join(' ').inspect}" }
      action.new(arguments).call
    end

    def cancel
      Log.separator
      Log.error { "  Unknown action: #{name}".red }
      Log.error { '  Try '.cyan + 'bio help'.bold }
      Log.separator

      raise Errors::UnknownActionError
    end

    def action
      @action ||= Actions.find(name)
    end

  end
end
