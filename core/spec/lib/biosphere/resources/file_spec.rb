require 'spec_helper'
require 'biosphere/resources/file'
require 'tempfile'
require 'tmpdir'

RSpec.describe Biosphere::Resources::File do

  describe 'create' do
    it 'creates the file' do
      workdir = Pathname.new Dir.mktmpdir
      path = workdir.join 'some_file'
      expect(path).to_not exist
      described_class.new(path.to_s).create
      expect(path).to exist
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
    context 'with content' do
      it 'opens the file in overwrite mode and writes the contents' do
        workdir = Pathname.new Dir.mktmpdir
        path = workdir.join 'some_file'
        expect(path).to_not exist
        described_class.new(path.to_s).write 'something'
        expect(path).to exist
        expect(path.read).to eq 'something'
      end
    end

    context 'without content' do
      it 'does not require an argument' do
        workdir = Pathname.new Dir.mktmpdir
        path = workdir.join 'some_file'
        expect(path).to_not exist
        described_class.new(path.to_s).write
        expect(path).to exist
        expect(path.read).to eq ''
      end
    end
  end

  describe '#augment' do
    context 'file exists' do
      it 'opens the file in overwrite mode and writes the contents' do
        path = Pathname.new Tempfile.new('some_file')
        expect(path).to exist
        described_class.new(path).augment 'content'
        expect(path.read).to include 'BIOSPHERE'
      end
    end
  end

  describe '#delete' do
    context 'file exists' do
      it 'deletes the file' do
        path = Pathname.new Tempfile.new('some_file')
        expect(path).to exist
        described_class.new(path).delete
        expect(path).to_not exist
      end
    end
  end

end
