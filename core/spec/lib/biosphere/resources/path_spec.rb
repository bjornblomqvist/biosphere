require 'spec_helper'
require 'biosphere/resources/path'

describe Biosphere::Resources::Path do

  let(:pathname) { double(:pathname, :exist? => false)}
  let(:path)     { Biosphere::Resources::Path.new '/tmp/some/path' }

  before do
    allow(Pathname).to receive(:new).and_return pathname
  end

  describe 'initialize' do
    it 'creates a pathname object' do
      expect(Pathname).to receive(:new).with('/tmp/some/path').and_return pathname
      expect(path.path).to eq(pathname)
    end

    it 'accepts a Path instance as argument' do
      expect(Pathname).to receive(:new).with('/tmp/some/path').and_return pathname
      expect(Biosphere::Resources::Path.new(path).path).to eq(pathname)
    end
  end

  describe '.create' do
    it 'delegates to the instance' do
      new_path = double(:path)
      expect(new_path).to receive(:create)
      expect(Biosphere::Resources::Path).to receive(:new).with('/tmp/my/path').and_return new_path
      Biosphere::Resources::Path.create '/tmp/my/path'
    end
  end

  describe '.delete' do
    it 'delegates to the instance' do
      new_path = double(:path)
      expect(new_path).to receive(:delete)
      expect(Biosphere::Resources::Path).to receive(:new).with('/tmp/deletable/path').and_return new_path
      Biosphere::Resources::Path.delete '/tmp/deletable/path'
    end
  end

  describe '#to_s' do
    it 'delegates to the pathname object' do
      expect(pathname).to receive(:to_s).and_return 'my/path'
      expect(path.to_s).to eq('my/path')
    end
  end

  context 'the path does not exist' do
    describe '#create' do
      it 'delegates to #create! if the path does not exist' do
        expect(path).to receive(:create!)
        expect(path.create).to eq(path)
      end
    end

    describe '#delete' do
      it 'does nothing if the path does not exist' do
        expect(path).not_to receive(:delete!)
        expect(path.delete).to eq(path)
      end
    end

    describe '#exists?' do
      it 'is false' do
        expect(path).not_to be_exists
      end
    end

    describe '#join' do
      it 'joins to the underlying pathname' do
        expect(pathname).to receive(:join).with('some/subpath')
        path.join('some/subpath')
      end
    end
  end

  context 'the path exists' do
    before do
      allow(pathname).to receive(:exist?).and_return true
    end

    describe '#create' do
      it 'does nothing if the path exists' do
        expect(path).not_to receive(:create!)
        expect(path.create).to eq(path)
      end
    end

    describe '#delete' do
      it 'delegates to #delete! if the path exists' do
        expect(path).to receive(:delete!)
        expect(path.delete).to eq(path)
      end
    end

    describe '#exists?' do
      it 'is true' do
        expect(path).to be_exists
      end
    end
  end

end
