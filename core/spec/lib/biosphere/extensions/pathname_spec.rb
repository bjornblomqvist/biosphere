require 'spec_helper'
require 'biosphere/extensions/pathname'

describe Biosphere::Extensions::PathnameExtensions do

  before do
    allow(Pathname).to receive(:home_env).and_return '/Users/bob'
  end

  describe '.home_path' do
    it 'is the home path' do
      expect(Pathname.home_path.to_s).to eq('/Users/bob')
    end
  end

  describe '#augment' do
    let(:augmentor) { double(:augmentor) }
    let(:pathname)  { Pathname.new('/an/augmentable/path') }

    it 'proxies to the Augmentor' do
      expect(Biosphere::Tools::Augmentor).to receive(:new).with(:file => pathname, :content => 'snow').and_return augmentor
      expect(augmentor).to receive(:perform)
      pathname.augment('snow')
    end
  end

  context 'under the home directory' do
    let(:pathname) { Pathname.new('/Users/bob/some/pathname') }

    describe '#unexpand_path' do
      it 'replaces the home path with tilde' do
        expect(pathname.unexpand_path.to_s).to eq('~/some/pathname')
      end
    end
  end

  context 'outside of the home directory' do
    let(:pathname) { Pathname.new('/tmp/absolute/pathname') }

    describe '#unexpand_path' do
      it 'returns the path as it is' do
        expect(pathname.unexpand_path.to_s).to eq('/tmp/absolute/pathname')
      end
    end
  end

  context 'a relative path' do
    let(:pathname) { Pathname.new('../relative/pathname') }

    describe '#unexpand_path' do
      it 'returns the path as it is' do
        expect(pathname.unexpand_path.to_s).to eq('../relative/pathname')
      end
    end
  end
end
