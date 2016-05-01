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
        ensure_cookbooks
        ensure_knife_config
        run_chef
      end

      def ensure_cookbooks
        if remote_cookbooks?
          Log.debug { 'You specified the `cookbooks_repo:` option in your sphere.yml so I will now sync with those remote cookbooks.' }
          load_remote_cookbooks
        else
          Log.debug { 'You did not specify any `cookbooks_repo:` in your sphere.yml so there are no remote cookbooks to sync with.' }
          load_local_cookbooks
        end
      end

      def load_remote_cookbooks
        if cookbooks_path.exist?
          update_cookbooks
        else
          clone_cookbooks
        end
      end

      def load_local_cookbooks
        if config.cookbooks_path.to_s == ''
          Log.error { 'You did not specify any `cookbooks_path:` in your sphere.yml.' }
          raise Errors::NoCookbooksPathDefined
        elsif !cookbooks_path.exist?
          Log.error { "Could not find any cookbooks at #{config.cookbooks_path.inspect} which you specified as `cookbooks_path:` in your sphere.yml" }
          raise Errors::LocalCookbooksNotFound
        else
          Log.debug { "I found the local cookbooks #{config.cookbooks_path.inspect} you specified as `cookbooks_path:` in your sphere.yml" }
        end
      end

      def clone_cookbooks
        Log.info { "Cloning remote cookbooks from #{cookbooks_repo}" }
        Log.info { "Cloning into #{cookbooks_repo_path}" }
        arguments = %W(clone #{cookbooks_repo} #{cookbooks_repo_path})
        result = Resources::Command.new(executable: :git, arguments: arguments).call

        if result.success?
          Log.debug { 'Successfully cloned remote cookbooks.' }
        else
          Log.error { "Failed to clone remote bookbooks. Use the --debug flag for more information." }
          fail Errors::CouldNotCloneRemoteCookbooks
        end
      end

      def update_cookbooks
        Log.info { "Updating remote cookbooks from #{cookbooks_repo}" }
        result = update_cookbooks_command.call

        if result.success?
          Log.info { "Cookbooks were updated." }
        else
          Log.error { "Could not update cookbooks: #{result.stdout.strip} #{result.stderr.strip}" }
          raise Errors::CouldNotUpdateRemoteCookbooks
        end
      end

      def update_cookbooks_command
        arguments = %W(--work-tree #{cookbooks_repo_path} --git-dir #{cookbooks_repo_path.join('.git')} pull origin master)
        Resources::Command.new executable: :git, arguments: arguments
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

      def remote_cookbooks?
        config.cookbooks_repo.to_s != ''
      end

      def cookbooks_repo
        return @cookbooks_repo if defined? @cookbooks_repo
        @cookbooks_repo = cookbooks_repo!
      end

      def cookbooks_repo!
        return unless config.cookbooks_repo
        result = Pathname.new config.cookbooks_repo
        Log.debug { "The remote cookbooks repository is located at #{result}" }
        result
      end

      def cookbooks_repo_name
        return @cookbooks_repo_name if defined? @cookbooks_repo_name
        @cookbooks_repo_name = cookbooks_repo_name!
      end

      def cookbooks_repo_name!
        return unless cookbooks_repo
        result = File.basename cookbooks_repo.to_s.split('/').last, '.*'
        Log.debug { "The cookbooks repository name is #{result}" }
        result
      end

      def cookbooks_repo_path
        cookbooks_container_path.join cookbooks_repo_name
      end

      def cookbooks_path
        @cookbooks_path ||= cookbooks_path!
      end

      def cookbooks_path!
        if config.cookbooks_repo.to_s == ''
          result = Pathname.new File.expand_path(config.cookbooks_path)
        else
          result = cookbooks_repo_path.join config.cookbooks_path
        end
        Log.debug { "Using cookbooks located at #{result}" }
        result
      end

      def cookbooks_container_path
        @cookbooks_container_path ||= cookbooks_container_path!
      end

      def cookbooks_container_path!
        result = sphere.path.join('cookbooks')
        Log.debug { "The cookbooks container is located at #{result.to_s}" }
        result
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
