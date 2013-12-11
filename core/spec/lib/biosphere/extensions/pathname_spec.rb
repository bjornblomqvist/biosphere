require 'spec_helper'
require 'biosphere/extensions/pathname'

describe Biosphere::Extensions::PathnameExtensions do

  before do
    Pathname.stub(:home_env).and_return '/Users/bob'
  end

  describe '.home_path' do
    it 'is the home path' do
      Pathname.home_path.to_s.should == '/Users/bob'
    end
  end

  describe '#augment' do
    let(:augmentor) { mock(:augmentor) }
    let(:pathname)  { Pathname.new('/an/augmentable/path') }

    it 'proxies to the Augmentor' do
      Biosphere::Tools::Augmentor.should_receive(:new).with(:file => pathname, :content => 'snow').and_return augmentor
      augmentor.should_receive(:perform)
      pathname.augment('snow')
    end
  end

  context 'under the home directory' do
    let(:pathname) { Pathname.new('/Users/bob/some/pathname') }

    describe '#unexpand_path' do
      it 'replaces the home path with tilde' do
        pathname.unexpand_path.to_s.should == '~/some/pathname'
      end
    end
  end

  context 'outside of the home directory' do
    let(:pathname) { Pathname.new('/tmp/absolute/pathname') }

    describe '#unexpand_path' do
      it 'returns the path as it is' do
        pathname.unexpand_path.to_s.should == '/tmp/absolute/pathname'
      end
    end
  end

  context 'a relative path' do
    let(:pathname) { Pathname.new('../relative/pathname') }

    describe '#unexpand_path' do
      it 'returns the path as it is' do
        pathname.unexpand_path.to_s.should == '../relative/pathname'
      end
    end
  end
end
