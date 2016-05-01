require 'uri'
require 'biosphere/extensions/hash'
require 'biosphere/extensions/string'
require 'biosphere/manager'
require 'biosphere/managers'
require 'biosphere/resources/command'
require 'biosphere/resources/file'
require 'biosphere/resources/gem'
require 'biosphere/runtime'
require 'biosphere/errors'
require 'biosphere/managers/chefsolos/gems'
require 'biosphere/managers/chefsolos/local_cookbooks'
require 'biosphere/managers/chefsolos/remote_cookbooks'
require 'biosphere/managers/chefsolos/paths'

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
        ensure_knife_config
        run_chef
      end

      def ensure_knife_config
        Resources::File.write paths.knife_config, knife_config_template
        Resources::File.write paths.solo_json, chef_json_template
      end

      def knife_config_template
        <<-END.undent
          cache_options    path: "#{paths.checksums}"
          cookbook_path    %w(#{cookbooks_path})
          file_backup_path "#{paths.backups}"
          file_cache_path  "#{paths.cache}"
          log_level        #{(Runtime.debug_mode? ? :debug : :info).inspect}
          verbose_logging  #{(Runtime.debug_mode? ? true : false).inspect}
        END
      end

      def chef_json_template
        %{{ "run_list": "recipe[biosphere]" }}
      end

      def run_chef
        result = run_chef!
        fail! unless result.success?
        result
      end

      def run_chef!
        Log.info { "Running Chef Solo to update sphere #{sphere.name.inspect}..." }
        chef_command.call
      end

      def chef_command
        Resources::Command.new show_output: true,
                               env_vars: env_vars,
                               executable: Paths.ruby_executable,
                               arguments: chef_arguments
      end

      def chef_arguments
        [gems.chef_solo_executable, '--config', paths.knife_config, '--json-attributes', paths.solo_json]
      end

      def fail!
        Log.separator
        Log.error { 'Chef Solo failed to run.'.red }
        Log.error { 'Please inspect the output above to find the broken cookbook.'.red }
        Log.separator
        raise Errors::ChefSoloRunFailed
      end

      def paths
        Chefsolos::Paths.new(sphere: sphere)
      end

      def gems
        Chefsolos::Gems.new version: config.chef_version
      end

      def remote_cookbooks
        Chefsolos::RemoteCookbooks.new sphere: sphere, config: config
      end

      def local_cookbooks
        Chefsolos::LocalCookbooks.new sphere: sphere, config: config
      end

      def cookbooks_path
        local_cookbooks.path || remote_cookbooks.cookbooks_path || cookbooks_path_not_found!
      end

      def cookbooks_path_not_found!
        Log.separator
        Log.error { 'You forgot to specify `cookbooks_repo:` or `cookbooks_path:` in your sphere.yml'.red }
        Log.error { 'Please have a look at the example sphere.yml you generated with `bio create`'.red }
        Log.separator
        raise Errors::NoCookbooksDefined
      end

    end
  end
end

Biosphere::Managers.register Biosphere::Managers::Chefsolo
