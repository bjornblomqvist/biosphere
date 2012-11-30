require 'biosphere/managers/default'
require 'biosphere/resources/gem'
require 'biosphere/resources/directory'
require 'biosphere/resources/file'
require 'biosphere/resources/command'
require 'biosphere/runtime'

module Biosphere
  module Managers
    class Chef < Default

      def perform
        Log.debug "Manager #{name} will now update sphere #{sphere.name}..."
        Log.info "Updating sphere #{sphere.name}..."
        ensure_chef
        ensure_knife_config
        run_chef
      end

      private

      def run_chef
        Log.info "Running chef to update sphere #{sphere.name.bold}..."
        chef_command.run
      end

      def ensure_knife_config
        Resources::File.write chef_knife_config_path, knife_config_template
      end

      def knife_config
        {
          :chef_server_url  => 'localhost',
          :validation_key   => '/dev/null',
          :node_name        => 'default_node_name.biosphere',
          :log_level        => (Runtime.debug_mode? ? :debug : :info),
          :verbose_logging  => (Runtime.debug_mode? ? true : false),
        }.merge(config.to_h)
      end

      def knife_config_template
        result = <<-END
          cache_options    :path => "#{chef_checksums_path}"
          chef_server_url  "#{knife_config[:chef_server_url]}"
          client_key       "#{chef_client_key_path.join(knife_config[:node_name] + '.pem')}"
          file_backup_path "#{chef_backups_path}"
          file_cache_path  "#{chef_cache_path}"
          log_level        #{knife_config[:log_level].to_sym.inspect}
          node_name        "#{knife_config[:node_name]}"
          validation_key   "#{knife_config[:validation_key]}"
          verbose_logging  #{knife_config[:verbose_logging].inspect}
        END
        result.split("\n").map(&:strip).join("\n")
      end

      def chef_client_key_path
        Resources::Directory.ensure workdir_path.join('client_keys')
      end

      def chef_checksums_path
        Resources::Directory.ensure chef_workdir_path.join('checksums')
      end

      def chef_cache_path
        Resources::Directory.ensure chef_workdir_path.join('cache')
      end

      def chef_backups_path
        Resources::Directory.ensure chef_workdir_path.join('backups')
      end

      def chef_knife_config_path
        workdir_path.join('knife.rb')
      end

      def chef_workdir_path
        Resources::Directory.ensure workdir_path.join('cache')
      end

      def workdir_path
        Resources::Directory.ensure sphere.cache_path.join('chef')
      end

      def ensure_chef
        chef_gem.ensure_installed
      end

      def chef_gem
        @chef_gem ||= Resources::Gem.new(:name => :chef, :version => chef_version)
      end

      def chef_version
        config.chef_version || default_chef_version
      end

      def default_chef_version
        '10.14.2'
      end

    end
  end
end