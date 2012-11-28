require 'biosphere/managers/default'
require 'biosphere/resources/gem'
require 'biosphere/resources/filesystem'
require 'biosphere/runtime'

module Biosphere
  module Managers
    class Chefserver < Default

      def perform
        Log.debug "Manager #{name} will now update sphere #{sphere.name}..."
        ensure_chef
        ensure_knife_config
        run_chef
      end


      private

      def run_chef
        Log.debug "Command to run: #{chef_command_arguments.join(' ')}"

      end

      def chef_command_arguments
        result = ["GEM_HOME=#{Resources::Gem.rubygems_path}", BIOSPHERE_RUBY_EXECUTABLE_PATH, chef_client_executable_path, '--config', chef_knife_config_path]
        result << '--log_level debug' if Runtime.debug_mode?
        result
      end

      def ensure_knife_config
        Resources::Filesystem.write_to_file chef_knife_config_path, knife_config
      end

      def knife_config
        #options= default_knife_options.merge!(sphere.config)
        <<-END
          chef_server_url "#{sphere.config.server_endpoint}"
          validation_key "#{sphere.config.validation_key_path}"
          node_name "#{sphere.config.client_name}"
          client_key "#{chef_client_key_path.join(sphere.config.client_name + '.pem')}"
          file_cache_path  "#{chef_cache_path}"
          file_backup_path "#{chef_backups_path}"
          cache_options({ :path => "#{chef_checksums_path}"})
        END
      end

      def default_knife_options
        {
          'server_endpoint'     => 'localhost',
          'validation_key_path' => '/dev/null',
          'client_name'         => 'biosphere_client',
          'run_list'            => 'recipe[biosphere]',
        }
      end

      def chef_client_key_path
        Resources::Filesystem.ensure_directory workdir_path.join('client_keys')
      end

      def chef_checksums_path
        Resources::Filesystem.ensure_directory chef_workdir_path.join('checksums')
      end

      def chef_cache_path
        Resources::Filesystem.ensure_directory chef_workdir_path.join('cache')
      end

      def chef_backups_path
        Resources::Filesystem.ensure_directory chef_workdir_path.join('backups')
      end

      def chef_knife_config_path
        workdir_path.join('knife.rb')
      end

      def chef_workdir_path
        Resources::Filesystem.ensure_directory workdir_path.join('cache')
      end

      def workdir_path
        Resources::Filesystem.ensure_directory sphere.cache_path.join('chef')
      end

      def chef_client_executable_path
        chef_gem.executables_path.join('chef-client')
      end

      def ensure_chef
        chef_gem.ensure_installed
      end

      def chef_gem
        @chef_gem ||= Resources::Gem.new(:name => :chef, :version => chef_version)
      end

      def chef_version
        sphere.config.chef_version || default_chef_version
      end

      def default_chef_version
        '10.14.2'
      end

    end
  end
end

Biosphere::Manager.register Biosphere::Managers::Chefserver