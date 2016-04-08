require 'spec_helper'
require 'biosphere/action'
require 'biosphere/actions/help'
require 'biosphere/actions/version'

RSpec.describe Biosphere::Action do

  describe '.call' do

    context 'no action specified' do
      it 'loads the help and does not raise any errors' do
        instance = described_class.new
        expect(instance.send(:action)).to eq Biosphere::Actions::Help
        instance.call
      end

      it 'instantiates the help class with the correct arguments' do
        instance = described_class.new
        action_instance = Biosphere::Actions::Help.new([])
        expect(Biosphere::Actions::Help).to receive(:new).with([]).and_return action_instance
        expect(action_instance).to receive(:call)
        instance.call
      end
    end

    context 'just the action name provided' do
      it 'loads that action' do
        instance = described_class.new ['version']
        expect(instance.send(:action)).to eq Biosphere::Actions::Version
        instance.call
      end
    end

    context 'the action name is unknown' do
      it 'raises an Error' do
        instance = described_class.new ['definitely_not_this']
        expect(instance.send(:action)).to be_nil
        expect { instance.call }.to raise_error Biosphere::Errors::UnknownActionError
      end
    end
  end

end
