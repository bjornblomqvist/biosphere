require 'spec_helper'

RSpec.describe Biosphere::Logger do

  describe '.debug' do
    context 'normal mode' do
      it 'is silent' do
        logger = described_class.new
        expect(logger).to_not receive(:output)
        logger.debug { 'Under the hood' }
      end
    end

    context 'debug mode' do
      it 'outputs a message with level prefix' do
        allow(Biosphere::Runtime).to receive(:debug_mode?).and_return true
        logger = described_class.new
        expect(logger).to receive(:output).with 'DEBUG: '.blue + 'Under the hood'
        logger.debug { 'Under the hood' }
      end
    end
  end

  describe '.info' do
    context 'normal mode' do
      it 'outputs a raw message' do
        logger = described_class.new
        expect(logger).to receive(:output).with 'Just for your info'
        logger.info { 'Just for your info' }
      end
    end

    context 'debug mode' do
      it 'outputs a message with level prefix' do
        allow(Biosphere::Runtime).to receive(:debug_mode?).and_return true
        logger = described_class.new
        expect(logger).to receive(:output).with 'INFO : Just for your info'
        logger.info { 'Just for your info' }
      end
    end

    context 'nil as message' do
      it 'outputs an empty message with level prefix' do
        logger = described_class.new
        expect(logger).to receive(:output).with nil
        logger.info { }
      end
    end
  end

  describe '.warn' do
    context 'normal mode' do
      it 'outputs a raw message' do
        logger = described_class.new
        expect(logger).to receive(:output).with 'Could be dangerous'
        logger.warn { 'Could be dangerous' }
      end
    end

    context 'debug mode' do
      it 'outputs a message with level prefix' do
        allow(Biosphere::Runtime).to receive(:debug_mode?).and_return true
        logger = described_class.new
        expect(logger).to receive(:output).with 'WARN : '.yellow + 'Could be dangerous'
        logger.warn { 'Could be dangerous' }
      end
    end
  end

  describe '.error' do
    context 'normal mode' do
      it 'outputs a raw message' do
        logger = described_class.new
        expect(logger).to receive(:output).with 'Oh no'
        logger.error { 'Oh no' }
      end
    end

    context 'debug mode' do
      it 'outputs a message with level prefix' do
        allow(Biosphere::Runtime).to receive(:debug_mode?).and_return true
        logger = described_class.new
        expect(logger).to receive(:output).with 'ERROR: '.red + 'Oh no'
        logger.error { 'Oh no' }
      end
    end
  end

  describe '.separator' do
    context 'any time' do
      it 'prints a new line' do
        logger = described_class.new
        expect(logger).to receive(:output).with no_args()
        logger.separator
      end
    end
  end

  describe '.output' do
    context 'in production' do
      it 'simply puts the string' do
        Biosphere::Runtime.env = :production
        logger = described_class.new
        expect(logger).to receive(:puts).with('Show me')
        logger.send(:output, 'Show me')
      end
    end
  end

end
