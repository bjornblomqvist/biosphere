require 'spec_helper'
require 'tempfile'
require 'biosphere/tools/augmentor'

RSpec.describe Biosphere::Tools::Augmentor do

  let(:file)        { Tempfile.new('target') }
  let(:path)        { Pathname.new(file.path) }
  let(:content)     { 'Merry Christmas' }
  let(:new_content) { 'Be happy' }
  let(:augmentor)   { Biosphere::Tools::Augmentor.new :file => path, :content => content }

  after do
    file.close
    file.unlink
  end

  describe '#perform' do
    context 'file is empty' do
      it 'inserts the content' do
        expect(file.read).to be_empty  # Just making really sure
        augmentor.perform
        expect(file.read).to eq <<-END.undent


          ### BIOSPHERE MANAGED START ###

          Merry Christmas

          ### BIOSPHERE MANAGED STOP ###
          END
      end
    end

    context 'file is augmented' do
      let(:new_augmentor) { Biosphere::Tools::Augmentor.new :file => path, :content => new_content }

      before do
        augmentor.perform
      end

      it 'modifies the augmentation' do
        new_augmentor.perform
        expect(file.read).to eq <<-END.undent


          ### BIOSPHERE MANAGED START ###

          Be happy

          ### BIOSPHERE MANAGED STOP ###
          END
      end
    end
  end

end
