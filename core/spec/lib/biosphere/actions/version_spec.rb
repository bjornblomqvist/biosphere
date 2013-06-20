require 'spec_helper'
require 'biosphere/actions/version'

describe Biosphere::Actions::Version do

  let(:major)   { 0 }
  let(:minor)   { 9 }
  let(:tiny)    { 0 }

  let(:action) { Biosphere::Actions::Version.new @args }

  describe '.perform' do
    it 'reveals the full version string' do
      @args = []
      Biosphere::Log.should_receive(:info).with "Biosphere Version #{major}.#{minor}.#{tiny}"
      action.perform
    end

    it 'reveals just the version' do
      @args = %w{ --short }
      Biosphere::Log.should_receive(:info).with "#{major}.#{minor}.#{tiny}"
      action.perform
    end

    it 'reveals the major' do
      @args = %w{ --major }
      Biosphere::Log.should_receive(:info).with major
      Biosphere::Log.should_receive(:batch).with major
      action.perform
    end

    it 'reveals the minor' do
      @args = %w{ --minor }
      Biosphere::Log.should_receive(:info).with minor
      Biosphere::Log.should_receive(:batch).with minor
      action.perform
    end

    it 'reveals the tiny' do
      @args = %w{ --patch }
      Biosphere::Log.should_receive(:info).with tiny
      Biosphere::Log.should_receive(:batch).with tiny
      action.perform
    end

    it 'knows that biosphere pane will work with this version' do
      @args = %W{ --compatible-with-preference-pane #{major}.#{minor}.#{tiny + 5} }
      Biosphere::Log.should_receive(:batch) do |args|
        Biosphere::JSON.load(args)['status'].should include 'is compatible'
      end
      Biosphere::Log.should_receive(:info) do |args|
        args.should include 'is compatible'
      end
      action.perform
    end

    it 'knows that biosphere pane is too old' do
      @args = %W{ --compatible-with-preference-pane #{major}.#{minor - 1}.#{tiny} }
      Biosphere::Log.should_receive(:batch) do |args|
        Biosphere::JSON.load(args)['status'].should include 'too new for Preference Pane'
      end
      Biosphere::Log.should_receive(:error) do |args|
        args.should include 'is too new for Preference Pane'
      end
      expect { action.perform }.to raise_error Biosphere::Errors::BiospherePaneIsTooOld
    end

    it 'knows that biosphere pane is too new' do
      @args = %W{ --compatible-with-preference-pane #{major}.#{minor + 1}.#{tiny} }
      Biosphere::Log.should_receive(:batch) do |args|
        Biosphere::JSON.load(args)['status'].should include 'too new for Biosphere'
      end
      Biosphere::Log.should_receive(:error) do |args|
        args.should include 'too new for Biosphere'
      end
      expect { action.perform }.to raise_error Biosphere::Errors::BiospherePaneIsTooNew
    end
  end

end