require 'spec_helper'
require 'biosphere/resources/directory'

RSpec.describe Biosphere::Resources::Directory do

  let(:pathname)  { double(:pathname, :exist? => false)}
  let(:directory) { Biosphere::Resources::Directory.new '/tmp/some/dir' }

  before do
    allow(Pathname).to receive(:new).and_return pathname
  end

  describe 'create' do
    it 'creates the directory' do
      expect(pathname).to receive(:mkdir)
      directory.create
    end
  end

end
