require 'spec_helper'
require 'biosphere/resources/file'

RSpec.describe Biosphere::Resources::File do

  let(:io)       { double(:io) }
  let(:pathname) { double(:pathname, :exist? => false)}
  let(:file)     { Biosphere::Resources::File.new '/tmp/some/file' }

  before do
    allow(Pathname).to receive(:new).and_return pathname
  end

  describe 'create' do
    it 'creates the file' do
      expect(pathname).to receive(:open).with('a')
      file.create
    end
  end

  describe '.augment' do
    it 'delegates to the instance' do
      new_path = double(:path)
      expect(new_path).to receive(:augment).with('hollywood')
      expect(Biosphere::Resources::File).to receive(:new).with('/tmp/augmentable/file').and_return new_path
      Biosphere::Resources::File.augment '/tmp/augmentable/file', 'hollywood'
    end
  end

  describe '.write' do
    it 'delegates to the instance' do
      new_path = double(:path)
      expect(new_path).to receive(:write).with('balloon')
      expect(Biosphere::Resources::File).to receive(:new).with('/tmp/writable/file').and_return new_path
      Biosphere::Resources::File.write '/tmp/writable/file', 'balloon'
    end
  end

  describe '#write' do
    it 'opens the file in overwrite mode and writes the contents' do
      expect(io).to receive(:write).with('content')
      expect(pathname).to receive(:open).with('w').and_yield io
      file.write 'content'
    end

    it 'does not require an argument' do
      expect(io).to receive(:write).with(nil)
      expect(pathname).to receive(:open).with('w').and_yield io
      file.write
    end
  end

  describe '#augment' do
    it 'opens the file in overwrite mode and writes the contents' do
      expect(pathname).to receive(:augment).with('content')
      file.augment 'content'
    end
  end

end
