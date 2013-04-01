require 'spec_helper'
require 'biosphere/runtime'

describe Biosphere::Runtime do
  let(:runtime) { Biosphere::Runtime }

  after do
    runtime.send(:reset!)
  end

  describe '.arguments' do
    it 'is a duplication of ARGV' do
      ARGV.stub!(:dup).and_return %w{ one two --three }
      runtime.send(:reset!)
      runtime.arguments.should == %w{ one two --three }
    end

    it 'is frozen' do
      runtime.arguments.should be_frozen
    end

    it 'strips out runtime-related parameters' do
      ARGV.stub!(:dup).and_return %w{ some_parameter --debug --some-option }
      runtime.send(:reset!)
      runtime.arguments.should == %w{ some_parameter --some-option }
    end
  end

  describe '.privileged?' do
    it 'is false when not run with superuser privileges' do
      # Note that this test fails if you happen to run rspec with superuser privileges :)
      runtime.should_not be_privileged
    end

    it 'is true when run with superuser privileges' do
      Process.stub!(:uid).and_return 0
      runtime.should be_privileged
    end
  end

  describe '.debug_mode?' do
    it 'is false by default' do
      runtime.stub!(:arguments).and_return []
      runtime.should_not be_debug_mode
    end

    it 'is true when the corresponding ARGV was set' do
      runtime.stub!(:arguments).and_return %w{ --debug }
      runtime.should be_debug_mode
    end
  end

  describe '.silent_mode?' do
    it 'is false by default' do
      runtime.stub!(:arguments).and_return []
      runtime.should_not be_silent_mode
    end

    it 'is true when the corresponding ARGV was set' do
      runtime.stub!(:arguments).and_return %w{ --silent }
      runtime.should be_silent_mode
    end
  end

  describe '.batch_mode?' do
    it 'is false by default' do
      runtime.stub!(:arguments).and_return []
      runtime.should_not be_batch_mode
    end

    it 'is true when the corresponding ARGV was set' do
      runtime.stub!(:arguments).and_return %w{ --batch }
      runtime.should be_batch_mode
    end
  end

  describe '.help_mode?' do
    it 'is false by default' do
      runtime.stub!(:arguments).and_return []
      runtime.should_not be_help_mode
    end

    it 'is true when the corresponding ARGV was set' do
      runtime.stub!(:arguments).and_return %w{ --help }
      runtime.should be_help_mode
    end
  end

end
