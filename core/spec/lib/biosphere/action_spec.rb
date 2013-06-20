require 'spec_helper'
require 'biosphere/action'

describe Biosphere::Action do
  let(:arguments)    { %w{ my_action ready set --go } }
  let(:logger)       { Biosphere::Log }
  let(:action)       { mock(:action) }
  let(:action_class) { mock(:action_class, :name => 'Biosphere::Actions::MyAction') }

  let(:dispatcher) { Biosphere::Action }

  describe '.perform' do
    context 'there is no action' do
      it 'logs an error but does not raise anything' do
        logger.should_receive(:error).any_number_of_times
        dispatcher.perform arguments
      end
    end

    context 'the action is registered' do
      before do
        dispatcher.register action_class
      end

      it 'executes the action with parameters relevant for the action' do
        action_class.should_receive(:new).with(%w{ ready set --go }).and_return action
        action.should_receive(:perform)
        dispatcher.perform arguments
      end
    end
  end

end
