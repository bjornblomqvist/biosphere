require 'spec_helper'
require 'biosphere/extensions/pathname'

describe Biosphere::Extensions::PathnameExtensions do

  let(:pathname) { Pathname.new('/Users/bob/some/pathname') }

  before do
    Pathname.stub!(:home_env).and_return '/Users/bob'
  end

  describe '#unexpand_path' do
    it 'replaces the home path with tilde' do
      pathname.unexpand_path.to_s.should == '~/some/pathname'
    end
  end
end
