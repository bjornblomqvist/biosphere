require 'spec_helper'
require 'biosphere/resources/command'

RSpec.describe Biosphere::Resources::Command do

  let(:executable) { 'whoami' }
  let(:arguments)  { [] }
  let(:command)    { Biosphere::Resources::Command.new executable: executable, arguments: arguments }

  describe 'run' do
    context 'executable does not exist' do
      it 'logs nothing and has status -1' do
        command = described_class.new executable: '/tmp/does_certainly_not_exist'
        expect(Biosphere::Log).to_not receive(:info)
        result = command.call
        expect(result).not_to be_success
        expect(result.status).to eq -1
      end
    end

    context 'command fails' do
      it 'has the status of the failed command' do
        command = described_class.new executable: '/bin/bash', arguments: ['-c', "'exit 15'"]
        expect(Biosphere::Log).to_not receive(:info)
        result = command.call
        expect(result).not_to be_success
        expect(result.status).to eq 15
      end
    end

    context 'command suceeds' do
      it 'has status 0' do
        command = described_class.new executable: '/bin/bash', arguments: ['-c', 'echo "perfect"']
        expect(Biosphere::Log).to_not receive(:info)
        result = command.call
        expect(result).to be_success
        expect(result.status).to eq 0
      end
    end
  end

end
