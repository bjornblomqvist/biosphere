require 'spec_helper'
require 'tempfile'
require 'biosphere/tools/augmentor'

RSpec.describe Biosphere::Tools::Augmentor do

  #let(:file)        {  }
  #let(:path)        { Pathname.new(file.path) }
  #let(:content)     { 'Merry Christmas' }
  #let(:new_content) { 'Be happy' }
  #let(:augmentor)   { Biosphere::Tools::Augmentor.new :file => path, :content => content }
  #
  #after do
  #  file.close
  #  file.unlink
  #end

  describe '#perform' do
    context 'file is empty' do
      it 'inserts the content' do
        path = Pathname.new Tempfile.new('target')
        augmentor = described_class.new file: path, content: 'Merry Christmas'
        expect(path.read).to be_empty  # Just making really sure
        augmentor.perform
        expect(path.read).to eq <<-END.undent


          ### BIOSPHERE MANAGED START ###

          Merry Christmas

          ### BIOSPHERE MANAGED STOP ###

          END
      end
    end

    context 'file is augmented differently' do
      it 'modifies the augmentation' do
        path = Pathname.new Tempfile.new('target')
        augmentor1 = described_class.new file: path, content: 'Merry Christmas'
        augmentor2 = described_class.new file: path, content: 'Be happy'
        augmentor1.perform
        augmentor2.perform

        expect(path.read).to eq <<-END.undent


          ### BIOSPHERE MANAGED START ###

          Be happy

          ### BIOSPHERE MANAGED STOP ###

          END
      end
    end

    context 'file is already augmented' do
      it 'does not modify the augmentation' do
        path = Pathname.new Tempfile.new('target')
        result1 = described_class.new(file: path, content: 'Already done').perform
        result2 = described_class.new(file: path, content: 'Already done').perform

        expect(path.read).to eq <<-END.undent


          ### BIOSPHERE MANAGED START ###

          Already done

          ### BIOSPHERE MANAGED STOP ###

          END
        expect(result1.status).to eq :content_appended
        expect(result2.status).to eq :already_up_to_date
      end
    end

    context 'imploding' do
      it 'removes the augmentation' do
        path = Pathname.new Tempfile.new('target')
        path.open('w') do |io| io.write <<-END.undent
          top

          ### BIOSPHERE MANAGED START ###

          inside

          ### BIOSPHERE MANAGED STOP ###

          bottom
        END
        end
        described_class.new(file: path).perform
        expect(path.read).to eq <<-END.undent
          top


          bottom
        END
      end
    end
  end

end
