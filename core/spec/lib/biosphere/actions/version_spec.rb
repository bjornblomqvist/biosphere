require 'spec_helper'
require 'biosphere/actions/version'

RSpec.describe Biosphere::Actions::Version do

  let(:major)   { 0 }
  let(:minor)   { 9 }
  let(:tiny)    { 0 }

  let(:action) { Biosphere::Actions::Version.new @args }

  before do
    @args = []
  end

  describe '.perform' do
    it 'reveals the full version string' do
      expect(Biosphere::Log).to receive(:info).with "Biosphere Version #{major}.#{minor}.#{tiny}"
      action.perform
    end

    it 'reveals just the version' do
      @args = %w{ --short }
      expect(Biosphere::Log).to receive(:info).with "#{major}.#{minor}.#{tiny}"
      action.perform
    end

    it 'reveals the major' do
      @args = %w{ --major }
      expect(Biosphere::Log).to receive(:info).with major
      expect(Biosphere::Log).to receive(:batch).with major
      action.perform
    end

    it 'reveals the minor' do
      @args = %w{ --minor }
      expect(Biosphere::Log).to receive(:info).with minor
      expect(Biosphere::Log).to receive(:batch).with minor
      action.perform
    end

    it 'reveals the tiny' do
      @args = %w{ --patch }
      expect(Biosphere::Log).to receive(:info).with tiny
      expect(Biosphere::Log).to receive(:batch).with tiny
      action.perform
    end

    it 'knows that biosphere pane will work with this version' do
      @args = %W{ --compatible-with-preference-pane #{major}.#{minor}.#{tiny + 5} }
      expect(Biosphere::Log).to receive(:batch) do |args|
        expect(Biosphere::JSON.load(args)['status']).to include 'is compatible'
      end
      expect(Biosphere::Log).to receive(:info) do |args|
        expect(args).to include 'is compatible'
      end
      action.perform
    end

    it 'knows that biosphere pane is too old' do
      @args = %W{ --compatible-with-preference-pane #{major}.#{minor - 1}.#{tiny} }
      expect(Biosphere::Log).to receive(:batch) do |args|
        expect(Biosphere::JSON.load(args)['status']).to include 'too new for Preference Pane'
      end
      expect(Biosphere::Log).to receive(:error) do |args|
        expect(args).to include 'is too new for Preference Pane'
      end
      expect { action.perform }.to raise_error Biosphere::Errors::BiospherePaneIsTooOld
    end

    it 'knows that biosphere pane is too new' do
      @args = %W{ --compatible-with-preference-pane #{major}.#{minor + 1}.#{tiny} }
      expect(Biosphere::Log).to receive(:batch) do |args|
        expect(Biosphere::JSON.load(args)['status']).to include 'too new for Biosphere'
      end
      expect(Biosphere::Log).to receive(:error) do |args|
        expect(args).to include 'too new for Biosphere'
      end
      expect { action.perform }.to raise_error Biosphere::Errors::BiospherePaneIsTooNew
    end
  end

end
