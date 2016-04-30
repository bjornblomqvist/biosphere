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
        chef_zero_gem.call
        chef_gem.call
        load_remote_cookbooks
        ensure_knife_config
        ensure_cookbooks
        run_chef
      end

      def load_remote_cookbooks
        unless remote_cookbooks?
          Log.error { 'You did not specify any `cookbooks_repo:` in your sphere.yml so there are no remote cookbooks to sync with.' }
          return
        end

        if cookbooks_path.exist?
          update_cookbooks
        else
          clone_cookbooks
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

      def ensure_knife_config
        Resources::File.write chef_knife_config_path, knife_config_template
        Resources::File.write chef_json_path, chef_json_template
      end

      def run_chef
        Log.info { "Running chef solo to update sphere #{sphere.name.bold}..." }
        Log.separator
        result = chef_command.call
        Log.separator
        result
      end

      def command_line_arguments
        [chef_solo_executable_path, '--config', chef_knife_config_path, '--json-attributes', chef_json_path]
      end

      def chef_command
        Resources::Command.new show_output: true,
                               env_vars: env_vars,
                               executable: Paths.ruby_executable,
                               arguments: command_line_arguments
      end

      def remote_cookbooks?
        config.cookbooks_repo.to_s != ''
      end

      #def local_cookbooks?
      #  !remote_cookbooks?
      #end

      def ensure_cookbooks
        if cookbooks_path && !cookbooks_path.exist?
          Log.error { "You did not specify where to find the cookbooks by using `cookbooks_path: /some/path` in your sphere.yml." }
        end
      end


      def update_cookbooks
        return if @updated_cookbooks
        if config.cookbooks_repo.to_s == ''
          Log.info { 'Not updating cookbooks because there is no remote' }
          return
        end

        Log.info { "Updating remote cookbooks from #{cookbooks_repo}" }
        result = update_cookbooks_command.call

        if result.success?
          Log.info { "Cookbooks were updated." }
          @updated_cookbooks = true
        else
          message = "Could not update cookbooks: #{result.stdout.strip} #{result.stderr.strip}"
          Log.error message
          raise Errors::CouldNotUpdateRemoteCookbooks, message
        end
      end

      def update_cookbooks_command
        arguments = %W(--work-tree #{cookbooks_repo_path} --git-dir #{cookbooks_repo_path.join('.git')} pull origin master)
        Resources::Command.new executable: :git, arguments: arguments
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
        if config.cookbooks_path.to_s == ''
          Log.error { "You did not specify any `cookbooks_path:` in your sphere.yml." }
          raise Errors::NoCookbooksPathDefined
        else
          Log.debug { "sphere.yml specified the following cookbooks_path: #{config.cookbooks_path.inspect}" }
        end

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

      def chef_solo_executable_path
        chef_gem.executables_path.join('chef-solo')
      end

      def chef_json_path
        workdir_path.join('solo.json')
      end

      def chef_client_key_path
        result = workdir_path.join('client_keys')
        result.mkpath
        result
      end

      def chef_checksums_path
        result = chef_workdir_path.join('checksums')
        result.mkpath
        result
      end

      def chef_cache_path
        result = chef_workdir_path.join('cache')
        result.mkpath
        result
      end

      def chef_backups_path
       result = chef_workdir_path.join('backups')
       result.mkpath
       result
      end

      def chef_knife_config_path
        workdir_path.join('knife.rb')
      end

      def chef_workdir_path
        result = workdir_path.join('cache')
        result.mkpath
        result
      end

      def workdir_path
        result = sphere.cache_path.join('chef')
        result.mkpath
        result
      end

      # –––––––––––––––
      # Gem definitions
      # –––––––––––––––

      # chef-zero is a dependency of chef. This is the last version to support Ruby 2.0.0
      def chef_zero_gem
        Resources::Gem.new(name: 'chef-zero', version: '4.5.0')
      end

      def chef_gem
        Resources::Gem.new(name: :chef, version: chef_version)
      end

      def chef_version
        config.chef_version || default_chef_version
      end

      # Make sure it's compatible with the minimal Ruby version that Biosphere itself requires.
      def default_chef_version
        '12.8.1'
      end

    end
  end
end


Biosphere::Managers.register Biosphere::Managers::Chefsolo
