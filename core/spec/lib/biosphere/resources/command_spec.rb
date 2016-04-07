require 'spec_helper'
require 'biosphere/resources/command'

describe Biosphere::Resources::Command do

  let(:executable) { 'whoami' }
  let(:arguments)  { [] }
  let(:command)    { Biosphere::Resources::Command.new :executable => executable, :arguments => arguments }

  describe 'run' do
    context 'executable does not exist' do
      let(:executable) { '/tmp/does_certainly_not_exist' }

      it 'has status -1' do
        expect(Biosphere::Log).to receive(:error).with("Command not found: #{executable}")
        result = command.run
        expect(result).not_to be_success
        expect(result.status).to eq(-1)
      end
    end

    context 'command failed' do
      let(:executable) { '/bin/bash' }
      let(:arguments)  { %w{ -c 'exit 15' } }

      it 'has the status of the failed command' do
        result = command.run
        expect(result).not_to be_success
        expect(result.status).to eq(15)
      end
    end

    context 'command successful' do
      let(:executable) { '/bin/bash' }
      let(:arguments)  { %w{ -c 'echo "perfect"' } }

      it 'has status 0' do
        result = command.run
        expect(result).to be_success
        expect(result.status).to eq(0)
      end
    end

  end

end