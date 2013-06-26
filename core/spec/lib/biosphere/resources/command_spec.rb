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
        Biosphere::Log.should_receive(:error).with("Command not found: #{executable}")
        result = command.run
        result.should_not be_success
        result.status.should == -1
      end
    end

    context 'command failed' do
      let(:executable) { '/bin/bash' }
      let(:arguments)  { %w{ -c 'exit 15' } }

      it 'has the status of the failed command' do
        #Biosphere::Log.should_receive(:error).with("Command not found: #{executable}")
        result = command.run
        result.should_not be_success
        result.status.should == 15
      end
    end

  end

end