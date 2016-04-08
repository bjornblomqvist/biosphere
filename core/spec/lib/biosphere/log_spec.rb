require 'spec_helper'
require 'biosphere/log'

RSpec.describe Biosphere::Log do

  describe '.debug' do
    context 'message as string' do
      it 'demands a block' do
        expect { described_class.debug('My Message') }.to raise_error(ArgumentError)
      end
    end

    context 'message as block' do
      it 'delegates to the logger' do
        expect(described_class.send(:logger)).to receive(:debug) do |*args, &block|
          expect(args).to be_empty
          expect(block.call).to eq 'Hello World'
        end
        described_class.debug { 'Hello World' }
      end
    end
  end

  describe '.info' do
    context 'message as string' do
      it 'demands a block' do
        expect { described_class.info('My Message') }.to raise_error(ArgumentError)
      end
    end

    context 'message as block' do
      it 'delegates to the logger' do
        expect(described_class.send(:logger)).to receive(:info) do |*args, &block|
          expect(args).to be_empty
          expect(block.call).to eq 'Hello World'
        end
        described_class.info { 'Hello World' }
      end
    end
  end

  describe '.warn' do
    context 'message as string' do
      it 'demands a block' do
        expect { described_class.warn('My Message') }.to raise_error(ArgumentError)
      end
    end

    context 'message as block' do
      it 'delegates to the logger' do
        expect(described_class.send(:logger)).to receive(:warn) do |*args, &block|
          expect(args).to be_empty
          expect(block.call).to eq 'Hello World'
        end
        described_class.warn { 'Hello World' }
      end
    end
  end

  describe '.error' do
    context 'message as string' do
      it 'demands a block' do
        expect { described_class.error('My Message') }.to raise_error(ArgumentError)
      end
    end

    context 'message as block' do
      it 'delegates to the logger' do
        expect(described_class.send(:logger)).to receive(:error) do |*args, &block|
          expect(args).to be_empty
          expect(block.call).to eq 'Hello World'
        end
        described_class.error { 'Hello World' }
      end
    end
  end

  describe '.separator' do
    context 'any time' do
      it 'delegates to the logger' do
        expect(described_class.send(:logger)).to receive(:separator).with no_args()
        described_class.separator
      end
    end
  end

end
