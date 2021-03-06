require 'spec_helper'
require 'biosphere/resources/command'

RSpec.describe Biosphere::Resources::Command do

  describe '#call' do
    context 'executable does not exist' do
      it 'logs nothing and has status -1' do
        command = described_class.new executable: '/tmp/does_certainly_not_exist'
        expect(Biosphere::Log).to_not receive(:info)
        result = command.call
        expect(result).not_to be_success
        expect(result.status).to eq -1
        expect(result.to_s).to include 'status=-1'
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

    context 'with environment variables' do
      it 'has the variables available in the command' do
        env_vars = { some_var: 'You bet' }
        workdir = Pathname.new Dir.mktmpdir
        tmpfile = workdir.join('some_file')
        command = described_class.new working_directory: workdir, executable: '/bin/bash', arguments: ['-c', %('echo -n $SOME_VAR > #{tmpfile}')], env_vars: env_vars
        expect(Biosphere::Log).to_not receive(:info)
        result = command.call
        expect(result).to be_success
        expect(tmpfile.read).to eq "You bet"
      end
    end

    context 'with indentation' do
      it 'indents and strips the output' do
        command = described_class.new executable: '/bin/bash', arguments: ['-c', %('echo -n " indented "' && this_writes_to_stderr)], show_output: true, indent: 3
        lines = []
        checks = 0
        allow(Biosphere::Log).to receive(:info) do |*args, &block|
          expect(args).to be_empty
          checks += 1 if block.call.include?('indented')
          checks += 1 if block.call.include?('not found')
          checks += 1 if block.call.include?('this_writes_to_stderr')
          expect(checks).to eq 3 if lines.size == 2
        end
        result = command.call
        expect(result.stderr).to include 'not found'
        expect(result.stdout).to eq ' indented '
      end
    end

    context 'in debug mode' do
      it 'logs stdout and stderror as debug messages' do
        allow(Biosphere::Runtime).to receive(:debug_mode?).and_return true
        arguments = ['-c', %('echo 'hi' 2> printf' && sleep 0.05 && doesnotexist)]
        command = described_class.new executable: '/bin/bash', arguments: arguments
        lines = []
        allow(Biosphere::Log).to receive(:debug) do |*args, &block|
          expect(args).to be_empty
          lines << block.call
          expect(lines.last).to eq 'Switching working directory to: /tmp' if lines.size == 1
          expected_command = %(/bin/bash -c 'echo 'hi' 2> printf' && sleep 0.05 && doesnotexist)
          expect(lines.last).to eq %(Running command: #{expected_command}) if lines.size == 2
          expect(lines.last).to include 'Command runs with PID ' if lines.size == 3
          expect(lines.last).to eq "  STDOUT: hi\n" if lines.size == 4
          expect(lines.last).to include '  STDERR: sh: ' if lines.size == 5
          expect(lines.last).to include 'doesnotexist' if lines.size == 5
          expect(lines.last).to include "not found\n" if lines.size == 5
          expect(lines.last).to include 'Command exited with pid' if lines.size == 6
          expect(lines.last).to include 'exit 0' if lines.size == 7
        end
        command.call
      end
    end
  end

  describe '#to_s' do
    it 'is the command to be run' do
      command = described_class.new executable: '/bin/bash', arguments: ['-c', 'echo "perfect"']
      expect(command.to_s).to eq '/bin/bash -c echo "perfect"'
    end
  end

end
