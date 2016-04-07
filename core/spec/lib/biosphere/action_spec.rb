require 'spec_helper'
require 'biosphere/action'

describe Biosphere::Action do
  let(:arguments)    { %w{ my_action ready set --go } }
  let(:logger)       { Biosphere::Log }
  let(:action)       { double(:action) }
  let(:action_class) { double(:action_class, :name => 'Biosphere::Actions::MyAction') }

  let(:dispatcher) { Biosphere::Action }

  describe '.perform' do
    context 'there is no action' do
      it 'logs an error but does not raise anything' do
        allow(logger).to receive(:error)
        dispatcher.perform arguments
      end
    end

    context 'the action is registered' do
      before do
        dispatcher.register action_class
      end

      after do
        dispatcher.send :unregister, action_class
      end

      it 'executes the action with parameters relevant for the action' do
        expect(action_class).to receive(:new).with(%w{ ready set --go }).and_return action
        expect(action).to receive(:perform)
        dispatcher.perform arguments
      end
    end
  end

end
