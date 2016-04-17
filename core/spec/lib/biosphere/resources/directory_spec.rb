require 'spec_helper'
require 'biosphere/resources/directory'
require 'tmpdir'

RSpec.describe Biosphere::Resources::Directory do

  describe 'create' do
    it 'creates the directory' do
      workdir = Pathname.new Dir.mktmpdir
      path = workdir.join('some/dir')
      expect(path).to_not exist
      directory = described_class.new path.to_s
      directory.create
      expect(path).to exist
    end
  end

  describe 'clear' do
    context 'directory is already empty' do
      it 'deletes all files' do
        workdir = Pathname.new Dir.mktmpdir
        workdir.join('file1').open('w') { |io| io.write nil }
        workdir.join('file2').open('w') { |io| io.write nil }
        workdir.join('subdir').mkdir

        expect(workdir.children.size).to eq 3
        directory = described_class.new workdir.to_s
        operation = directory.clear
        expect(operation).to be_instance_of described_class
        expect(workdir.children.size).to eq 1
      end
    end
  end

end
