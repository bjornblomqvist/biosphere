require 'spec_helper'
require 'biosphere/actions/version'

RSpec.describe Biosphere::Actions::Version do

  describe '.call' do
    context 'no arguments' do
      it 'reveals the full version string' do
        expect(Biosphere::Log).to receive(:info) do |*args, &block|
          expect(args).to be_empty
          expect(block.call).to eq "Biosphere version #{Biosphere::VERSION}"
        end

        described_class.new.call
      end
    end

    context '--short' do
      it 'reveals only the version string' do
        expect(Biosphere::Log).to receive(:info) do |*args, &block|
          expect(args).to be_empty
          expect(block.call).to eq Biosphere::VERSION
        end

        described_class.new(['--short']).call
      end
    end

    context 'help' do
      it 'shows the help' do
        allow(Biosphere::Runtime).to receive(:help_mode?).and_return true
        instance = described_class.new
        instance.call
      end
    end
  end

end
