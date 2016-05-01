require 'spec_helper'
require 'biosphere/resources/gem'
require 'biosphere/paths'

RSpec.describe Biosphere::Resources::Gem do

  describe '#call' do
    context 'success when only the name specified' do
      it 'installs the gem' do
        instance = described_class.new name: :'gem-example'
        env_vars = { GEM_PATH: Biosphere::Paths.biosphere_home.join('vendor/gems/2.0.0') }
        executable = Pathname.new '/usr/bin/gem'
        arguments = %W(install gem-example --install-dir #{Biosphere::Paths.biosphere_home}/vendor/gems/2.0.0
                       --no-document --source https://rubygems.org)
        attributes = { env_vars: env_vars, executable: executable, arguments: arguments }
        command = double(:command)
        expect(command).to receive(:call).and_return OpenStruct.new(success?: true)
        expect(Biosphere::Resources::Command).to receive(:new).with(attributes).and_return command

        debugs = []
        expect(Biosphere::Log).to receive(:debug) do |*args, &block|
          expect(args).to be_empty
          debugs << block.call
          expect(debugs.last).to eq 'Successfully installed gem "gem-example"' if debugs.size == 1
        end

        infos = []
        expect(Biosphere::Log).to receive(:info).twice do |*args, &block|
          expect(args).to be_empty
          infos << block.call
          expect(infos.last).to eq 'Installing gem "gem-example"...' if infos.size == 1
          expect(infos.last).to eq 'This may take a while...' if infos.size == 2
        end

        expect(Biosphere::Log).to_not receive(:error)

        instance.call
      end
    end

    context 'success when name and version specified' do
      it 'installs the gem' do
        instance = described_class.new name: :'gem-example', version: '1.2.3'
        env_vars = { GEM_PATH: Biosphere::Paths.biosphere_home.join('vendor/gems/2.0.0') }
        executable = Pathname.new '/usr/bin/gem'
        arguments = %W(install gem-example --install-dir #{Biosphere::Paths.biosphere_home}/vendor/gems/2.0.0
                       --no-document --source https://rubygems.org --version 1.2.3)
        attributes = { env_vars: env_vars, executable: executable, arguments: arguments }
        command = double(:command)
        expect(command).to receive(:call).and_return OpenStruct.new(success?: true)
        expect(Biosphere::Resources::Command).to receive(:new).with(attributes).and_return command

        debugs = []
        expect(Biosphere::Log).to receive(:debug) do |*args, &block|
          expect(args).to be_empty
          debugs << block.call
          expect(debugs.last).to eq 'Successfully installed gem "gem-example" version "1.2.3"' if debugs.size == 1
        end

        infos = []
        expect(Biosphere::Log).to receive(:info).twice do |*args, &block|
          expect(args).to be_empty
          infos << block.call
          expect(infos.last).to eq 'Installing gem "gem-example" version "1.2.3"...' if infos.size == 1
          expect(infos.last).to eq 'This may take a while...' if infos.size == 2
        end

        expect(Biosphere::Log).to_not receive(:error)

        instance.call
      end
    end

    context 'failure when only the name specified' do
      it 'raises an error' do
        instance = described_class.new name: :'gem-example'
        command = double(:command)
        expect(command).to receive(:call).and_return OpenStruct.new(success?: false)
        expect(Biosphere::Resources::Command).to receive(:new).and_return command

        expect(Biosphere::Log).to_not receive(:debug)

        infos = []
        expect(Biosphere::Log).to receive(:info).twice do |*args, &block|
          expect(args).to be_empty
          infos << block.call
          expect(infos.last).to eq 'Installing gem "gem-example"...' if infos.size == 1
          expect(infos.last).to eq 'This may take a while...' if infos.size == 2
        end

        errors = []
        expect(Biosphere::Log).to receive(:error).twice do |*args, &block|
          expect(args).to be_empty
          errors << block.call
          expect(errors.last).to eq 'Could not install gem "gem-example". Are you online?'.red if errors.size == 1
          if errors.size == 2
            expect(errors.last).to eq 'Please try to run this command with the --debug flag for more details.'.red
          end
        end

        expect { instance.call }.to raise_error Biosphere::Errors::GemInstallationFailed
      end
    end

    context 'failure when name and version specified' do
      it 'raises an error' do
        instance = described_class.new name: :'gem-example', version: '1.2.3-beta4'
        command = double(:command)
        expect(command).to receive(:call).and_return OpenStruct.new(success?: false)
        expect(Biosphere::Resources::Command).to receive(:new).and_return command

        expect(Biosphere::Log).to_not receive(:debug)

        infos = []
        expect(Biosphere::Log).to receive(:info).twice do |*args, &block|
          expect(args).to be_empty
          infos << block.call
          expect(infos.last).to eq 'Installing gem "gem-example" version "1.2.3-beta4"...' if infos.size == 1
          expect(infos.last).to eq 'This may take a while...' if infos.size == 2
        end

        errors = []
        expect(Biosphere::Log).to receive(:error).twice do |*args, &block|
          expect(args).to be_empty
          errors << block.call
          expect(errors.last).to eq 'Could not install gem "gem-example" version "1.2.3-beta4". Are you online?'.red if errors.size == 1
          if errors.size == 2
            expect(errors.last).to eq 'Please try to run this command with the --debug flag for more details.'.red
          end
        end

        expect { instance.call }.to raise_error Biosphere::Errors::GemInstallationFailed
      end
    end
  end

end
