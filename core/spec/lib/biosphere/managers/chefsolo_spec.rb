require 'spec_helper'
require 'biosphere/managers'
require 'biosphere/managers/chefsolo'
require 'biosphere/resources/sphere'

RSpec.describe Biosphere::Managers::Chefsolo do

  describe '#call' do
    context 'no cookbooks defined' do
      it 'raises an error' do
        sphere = Biosphere::Resources::Sphere.new('test1')
        config = OpenStruct.new
        instance = described_class.new sphere: sphere, config: config
        gem_double = double(:gem, call: true, executables_path: Pathname.new('/dev/null/gems/bin'))
        expect(Biosphere::Resources::Gem).to receive(:new).twice.and_return gem_double

        expect { instance.call }.to raise_error Biosphere::Errors::NoCookbooksDefined
      end
    end

    context 'only remote cookbooks without subdirectory defined' do
      it 'runs chef with those cookbooks' do
        sphere = Biosphere::Resources::Sphere.new('test1')
        config = OpenStruct.new cookbooks_repo: '/dev/null/remote'
        instance = described_class.new sphere: sphere, config: config
        gem_double = double(:gem, call: true, executables_path: Pathname.new('/dev/null/gems/bin'))
        expect(Biosphere::Resources::Gem).to receive(:new).thrice.and_return gem_double

        command = double(:command)
        expect(command).to receive(:call).twice.and_return OpenStruct.new(success?: true)
        clone_arguments = %W(clone /dev/null/remote #{sphere.path}/cookbooks/null_remote)
        clone_attributes = { executable: :git, arguments: clone_arguments }
        expect(Biosphere::Resources::Command).to receive(:new).with(clone_attributes).and_return command

        knife_config_path = Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/knife.rb')
        solo_json_path = Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/solo.json')

        chef_env_vars = {
          GEM_HOME: Biosphere::Paths.biosphere_home.join('vendor/gems/2.0.0'),
          BIOSPHERE_HOME: Biosphere::Paths.biosphere_home,
          BIOSPHERE_SPHERE_NAME: 'test1',
          BIOSPHERE_SPHERE_PATH: Biosphere::Paths.biosphere_home.join('spheres/test1'),
          BIOSPHERE_SPHERE_AUGMENTATIONS_PATH: Biosphere::Paths.biosphere_home.join('spheres/test1/augmentations'),
        }
        chef_arguments = [Pathname.new('/dev/null/gems/bin/chef-solo'),
                          '--config', knife_config_path,
                          '--json-attributes', solo_json_path]
        chef_attributes = { show_output: true, env_vars: chef_env_vars,
                            executable: Pathname.new('/usr/bin/ruby'), arguments: chef_arguments }
        expect(Biosphere::Resources::Command).to receive(:new).with(chef_attributes).and_return command

        instance.call

        expect(knife_config_path.read).to eq <<-END.undent
          cache_options    path: "#{Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/cache/checksums')}"
          cookbook_path    %w(#{Biosphere::Paths.biosphere_home.join('spheres/test1/cookbooks/null_remote')})
          file_backup_path "#{Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/cache/backups')}"
          file_cache_path  "#{Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/cache/cache')}"
          log_level        :info
          verbose_logging  false
        END

        expect(solo_json_path.read).to eq '{ "run_list": "recipe[biosphere]" }'
      end
    end

    context 'remote cookbooks with subdirectory defined' do
      it 'runs chef with those cookbooks' do
        sphere = Biosphere::Resources::Sphere.new('test1')
        config = OpenStruct.new cookbooks_repo: '/dev/null/remote', cookbooks_repo_subdir: 'under/neath'
        instance = described_class.new sphere: sphere, config: config
        gem_double = double(:gem, call: true, executables_path: Pathname.new('/dev/null/gems/bin'))
        expect(Biosphere::Resources::Gem).to receive(:new).thrice.and_return gem_double

        command = double(:command)
        expect(command).to receive(:call).twice.and_return OpenStruct.new(success?: true)
        clone_arguments = %W(clone /dev/null/remote #{sphere.path}/cookbooks/null_remote)
        clone_attributes = { executable: :git, arguments: clone_arguments }
        expect(Biosphere::Resources::Command).to receive(:new).with(clone_attributes).and_return command

        knife_config_path = Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/knife.rb')
        solo_json_path = Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/solo.json')

        chef_env_vars = {
          GEM_HOME: Biosphere::Paths.biosphere_home.join('vendor/gems/2.0.0'),
          BIOSPHERE_HOME: Biosphere::Paths.biosphere_home,
          BIOSPHERE_SPHERE_NAME: 'test1',
          BIOSPHERE_SPHERE_PATH: Biosphere::Paths.biosphere_home.join('spheres/test1'),
          BIOSPHERE_SPHERE_AUGMENTATIONS_PATH: Biosphere::Paths.biosphere_home.join('spheres/test1/augmentations'),
        }
        chef_arguments = [Pathname.new('/dev/null/gems/bin/chef-solo'),
                          '--config', knife_config_path,
                          '--json-attributes', solo_json_path]
        chef_attributes = { show_output: true, env_vars: chef_env_vars,
                            executable: Pathname.new('/usr/bin/ruby'), arguments: chef_arguments }
        expect(Biosphere::Resources::Command).to receive(:new).with(chef_attributes).and_return command

        instance.call

        expect(knife_config_path.read).to eq <<-END.undent
          cache_options    path: "#{Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/cache/checksums')}"
          cookbook_path    %w(#{Biosphere::Paths.biosphere_home.join('spheres/test1/cookbooks/null_remote/under/neath')})
          file_backup_path "#{Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/cache/backups')}"
          file_cache_path  "#{Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/cache/cache')}"
          log_level        :info
          verbose_logging  false
        END

        expect(solo_json_path.read).to eq '{ "run_list": "recipe[biosphere]" }'
      end
    end

    context 'only local cookbooks defined' do
      it 'runs chef with those cookbooks' do
        sphere = Biosphere::Resources::Sphere.new('test1')
        local_cookbooks_path = Pathname.new(Dir.mktmpdir).join('local/cookbooks')
        local_cookbooks_path.mkpath

        config = OpenStruct.new cookbooks_path: local_cookbooks_path.to_s
        instance = described_class.new sphere: sphere, config: config
        gem_double = double(:gem, call: true, executables_path: Pathname.new('/dev/null/gems/bin'))
        expect(Biosphere::Resources::Gem).to receive(:new).thrice.and_return gem_double

        knife_config_path = Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/knife.rb')
        solo_json_path = Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/solo.json')

        chef_env_vars = {
          GEM_HOME: Biosphere::Paths.biosphere_home.join('vendor/gems/2.0.0'),
          BIOSPHERE_HOME: Biosphere::Paths.biosphere_home,
          BIOSPHERE_SPHERE_NAME: 'test1',
          BIOSPHERE_SPHERE_PATH: Biosphere::Paths.biosphere_home.join('spheres/test1'),
          BIOSPHERE_SPHERE_AUGMENTATIONS_PATH: Biosphere::Paths.biosphere_home.join('spheres/test1/augmentations'),
        }
        chef_arguments = [Pathname.new('/dev/null/gems/bin/chef-solo'),
                          '--config', knife_config_path,
                          '--json-attributes', solo_json_path]
        chef_attributes = { show_output: true, env_vars: chef_env_vars,
                            executable: Pathname.new('/usr/bin/ruby'), arguments: chef_arguments }

        command = double(:command)
        expect(command).to receive(:call).and_return OpenStruct.new(success?: true)
        expect(Biosphere::Resources::Command).to receive(:new).with(chef_attributes).and_return command

        instance.call

        expect(knife_config_path.read).to eq <<-END.undent
          cache_options    path: "#{Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/cache/checksums')}"
          cookbook_path    %w(#{local_cookbooks_path})
          file_backup_path "#{Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/cache/backups')}"
          file_cache_path  "#{Biosphere::Paths.biosphere_home.join('spheres/test1/cache/chef/cache/cache')}"
          log_level        :info
          verbose_logging  false
        END

        expect(solo_json_path.read).to eq '{ "run_list": "recipe[biosphere]" }'
      end
    end
  end

end
