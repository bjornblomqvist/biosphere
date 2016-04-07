require 'spec_helper'
require 'biosphere/runtime'

describe Biosphere::Runtime do
  let(:runtime) { Biosphere::Runtime }

  before do
    allow(ARGV).to receive(:dup).and_return []
    runtime.send(:reset!)
  end

  describe '.arguments' do
    it 'is a duplication of ARGV' do
      allow(ARGV).to receive(:dup).and_return %w{ one two --three }
      expect(runtime.arguments).to eq(%w{ one two --three })
    end

    it 'is frozen' do
      expect(runtime.arguments).to be_frozen
    end

    it 'strips out runtime-related parameters' do
      allow(ARGV).to receive(:dup).and_return %w{ some_parameter --debug --some-option }
      expect(runtime.arguments).to eq(%w{ some_parameter --some-option })
    end
  end

  describe '.privileged?' do
    # Note that this test fails if you happen to run rspec with superuser privileges :)
    it 'is false when not run with superuser privileges' do
      expect(runtime).not_to be_privileged
    end

    it 'is true when run with superuser privileges' do
      allow(Process).to receive(:uid).and_return 0
      expect(runtime).to be_privileged
    end
  end

  describe '.debug_mode?' do
    it 'is false by default' do
      expect(runtime).not_to be_debug_mode
    end

    it 'is true when the corresponding ARGV was set' do
      allow(ARGV).to receive(:dup).and_return %w{ --debug }
      expect(runtime).to be_debug_mode
    end
  end

  describe '.silent_mode?' do
    it 'is false by default' do
      expect(runtime).not_to be_silent_mode
    end

    it 'is true when the corresponding ARGV was set' do
      allow(ARGV).to receive(:dup).and_return %w{ --silent }
      expect(runtime).to be_silent_mode
    end
  end

  describe '.batch_mode?' do
    it 'is false by default' do
      expect(runtime).not_to be_batch_mode
    end

    it 'is true when the corresponding ARGV was set' do
      allow(ARGV).to receive(:dup).and_return %w{ --batch }
      expect(runtime).to be_batch_mode
    end
  end

  describe '.help_mode?' do
    it 'is false by default' do
      expect(runtime).not_to be_help_mode
    end

    it 'is true when the corresponding ARGV was set' do
      allow(ARGV).to receive(:dup).and_return %w{ --help }
      expect(runtime).to be_help_mode
    end
  end

end
