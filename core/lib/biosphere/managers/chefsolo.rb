require 'uri'
require 'biosphere/extensions/hash'
require 'biosphere/extensions/string'
require 'biosphere/manager'
require 'biosphere/resources/command'
require 'biosphere/resources/directory'
require 'biosphere/resources/file'
require 'biosphere/resources/gem'
require 'biosphere/runtime'
require 'biosphere/errors'

module Biosphere
  module Managers
    class Chefsolo

      include ::Biosphere::Manager

      def call
        Log.debug { "Manager #{name.bold} will now update Sphere #{sphere.name.bold}..." }
        Log.info { "Updating Sphere #{sphere.name.bold}..." }
        call!
      end

      def name
        'Opscode Chef Solo'
      end

      def description
        'This Manager runs Chef locally in a standalone manner. \
          You have to provide the cookbooks via Github or a local directory.'
      end

      private

      def call!
        gems.call
        remote_cookbooks.call
        local_cookbooks.call

        #ensure_cookbooks
        #ensure_knife_config
        #run_chef
      end


      def ensure_knife_config
        Resources::File.write chef_knife_config_path, knife_config_template
        Resources::File.write chef_json_path, chef_json_template
      end

      def run_chef
        Log.info { "Running chef solo to update sphere #{sphere.name.bold}..." }
        Log.separator
        result = chef_command.call
        if result.success?
          Log.debug { "Chef solo ran successfully." }
        else
          Log.error { "Chef failed to run." }
          raise Errors::ChefSoloRunFailed
        end
        Log.separator
        result
      end

      def chef_command
        Resources::Command.new show_output: true,
                               env_vars: env_vars,
                               executable: Paths.ruby_executable,
                               arguments: chef_arguments
      end

      def chef_arguments
        [chef_solo_executable_path, '--config', chef_knife_config_path, '--json-attributes', chef_json_path]
      end


      # ––––––––––––––––––
      # Chef configuration
      # ––––––––––––––––––

      def chef_json_template
        %{{ "run_list": "#{chef_run_list}" }}
      end

      def chef_run_list
        knife_config[:runlist] || "recipe[biosphere]"
      end

      def knife_config
        {
          log_level:       (Runtime.debug_mode? ? :debug : :info),
          verbose_logging: (Runtime.debug_mode? ? true : false),
        }
      end

      def knife_config_template
        <<-END.undent
          cache_options    path: "#{chef_checksums_path}"
          cookbook_path    %w(#{cookbooks_path})
          file_backup_path "#{chef_backups_path}"
          file_cache_path  "#{chef_cache_path}"
          log_level        #{knife_config[:log_level].to_sym.inspect}
          verbose_logging  #{knife_config[:verbose_logging].inspect}
        END
      end

      # –––––
      # Paths
      # –––––

    end
  end
end


Biosphere::Managers.register Biosphere::Managers::Chefsolo
