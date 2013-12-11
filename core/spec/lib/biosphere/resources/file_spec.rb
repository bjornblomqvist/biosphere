require 'spec_helper'
require 'biosphere/resources/file'

describe Biosphere::Resources::File do

  let(:io)       { mock(:io) }
  let(:pathname) { mock(:pathname, :exist? => false)}
  let(:file)     { Biosphere::Resources::File.new '/tmp/some/file' }

  before do
    Pathname.stub(:new).and_return pathname
  end

  describe 'create' do
    it 'creates the file' do
      pathname.should_receive(:open).with('a')
      file.create
    end
  end

  describe '.augment' do
    it 'delegates to the instance' do
      new_path = mock(:path)
      new_path.should_receive(:augment).with('hollywood')
      Biosphere::Resources::File.should_receive(:new).with('/tmp/augmentable/file').and_return new_path
      Biosphere::Resources::File.augment '/tmp/augmentable/file', 'hollywood'
    end
  end

  describe '.write' do
    it 'delegates to the instance' do
      new_path = mock(:path)
      new_path.should_receive(:write).with('balloon')
      Biosphere::Resources::File.should_receive(:new).with('/tmp/writable/file').and_return new_path
      Biosphere::Resources::File.write '/tmp/writable/file', 'balloon'
    end
  end

  describe '#write' do
    it 'opens the file in overwrite mode and writes the contents' do
      io.should_receive(:write).with('content')
      pathname.should_receive(:open).with('w').and_yield io
      file.write 'content'
    end

    it 'does not require an argument' do
      io.should_receive(:write).with(nil)
      pathname.should_receive(:open).with('w').and_yield io
      file.write
    end
  end

  describe '#augment' do
    it 'opens the file in overwrite mode and writes the contents' do
      pathname.should_receive(:augment).with('content')
      file.augment 'content'
    end
  end

end
