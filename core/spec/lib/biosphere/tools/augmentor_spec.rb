require 'spec_helper'
require 'tempfile'
require 'biosphere/tools/augmentor'

describe Biosphere::Tools::Augmentor do

  let(:file)        { Tempfile.new('target') }
  let(:content)     { 'Merry Christmas' }
  let(:new_content) { 'Be happy' }
  let(:augmentor)   { Biosphere::Tools::Augmentor.new :file => file, :content => content }

  after do
    file.close
    file.unlink
  end

  describe '#perform' do
    context 'file is empty' do
      it 'inserts the content' do
        file.read.should be_empty  # Just making really sure
        augmentor.perform
        file.read.should == <<-END.undent


          ### BIOSPHERE MANAGED START ###

          Merry Christmas

          ### BIOSPHERE MANAGED STOP ###
          END
      end
    end

    context 'file is augmented' do
      let(:new_augmentor) { Biosphere::Tools::Augmentor.new :file => file, :content => new_content }

      before do
        augmentor.perform
      end

      it 'modifies the augmentation' do
        new_augmentor.perform
        file.read.should == <<-END.undent


          ### BIOSPHERE MANAGED START ###

          Be happy

          ### BIOSPHERE MANAGED STOP ###
          END
      end
    end
  end

end
