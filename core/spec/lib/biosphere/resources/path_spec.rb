require 'spec_helper'
require 'biosphere/resources/path'

describe Biosphere::Resources::Path do

  let(:pathname) { mock(:pathname, :exist? => false)}
  let(:path)     { Biosphere::Resources::Path.new '/tmp/some/path' }

  before do
    Pathname.stub(:new).and_return pathname
  end

  describe 'initialize' do
    it 'creates a pathname object' do
      Pathname.should_receive(:new).with('/tmp/some/path').and_return pathname
      path.path.should == pathname
    end

    it 'accepts a Path instance as argument' do
      Pathname.should_receive(:new).with('/tmp/some/path').and_return pathname
      Biosphere::Resources::Path.new(path).path.should == pathname
    end
  end

  describe '.create' do
    it 'delegates to the instance' do
      new_path = mock(:path)
      new_path.should_receive(:create)
      Biosphere::Resources::Path.should_receive(:new).with('/tmp/my/path').and_return new_path
      Biosphere::Resources::Path.create '/tmp/my/path'
    end
  end

  describe '.delete' do
    it 'delegates to the instance' do
      new_path = mock(:path)
      new_path.should_receive(:delete)
      Biosphere::Resources::Path.should_receive(:new).with('/tmp/deletable/path').and_return new_path
      Biosphere::Resources::Path.delete '/tmp/deletable/path'
    end
  end

  describe '#to_s' do
    it 'delegates to the pathname object' do
      pathname.should_receive(:to_s).and_return 'my/path'
      path.to_s.should == 'my/path'
    end
  end

  context 'the path does not exist' do
    describe '#create' do
      it 'delegates to #create! if the path does not exist' do
        path.should_receive(:create!)
        path.create.should == path
      end
    end

    describe '#delete' do
      it 'does nothing if the path does not exist' do
        path.should_not_receive(:delete!)
        path.delete.should == path
      end
    end

    describe '#exists?' do
      it 'is false' do
        path.should_not be_exists
      end
    end

    describe '#join' do
      it 'joins to the underlying pathname' do
        pathname.should_receive(:join).with('some/subpath')
        path.join('some/subpath')
      end
    end
  end

  context 'the path exists' do
    before do
      pathname.stub(:exist?).and_return true
    end

    describe '#create' do
      it 'does nothing if the path exists' do
        path.should_not_receive(:create!)
        path.create.should == path
      end
    end

    describe '#delete' do
      it 'delegates to #delete! if the path exists' do
        path.should_receive(:delete!)
        path.delete.should == path
      end
    end

    describe '#exists?' do
      it 'is true' do
        path.should be_exists
      end
    end
  end

end
