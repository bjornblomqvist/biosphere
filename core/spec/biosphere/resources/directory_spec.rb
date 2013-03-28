require 'spec_helper'
require 'biosphere/resources/directory'

describe Biosphere::Resources::Directory do

  let(:pathname)  { mock(:pathname, exist?: false)}
  let(:directory) { Biosphere::Resources::Directory.new '/tmp/some/dir' }

  before do
    Pathname.stub!(:new).and_return pathname
  end

  describe 'create' do
    it 'creates the directory' do
      pathname.should_receive(:mkdir)
      directory.create
    end
  end

end
