require 'biosphere/managers/chef'
require 'biosphere/resources/gem'
require 'biosphere/resources/command'
require 'biosphere/paths'

module Biosphere
  module Managers
    class Chefserver < Chef

      def name
        'Opscode Chef Server'
      end

      def description
        'This Manager connects to a remote Chef server and executes the remote cookbooks according to the configuration for your node.'
      end

      private

      def chef_command
        arguments = [chef_client_executable_path, '--config', chef_knife_config_path]
        arguments += ['--override-runlist', knife_config[:override_runlist]] if knife_config[:override_runlist]
        Resources::Command.new :show_output => true, :env_vars => default_env_vars, :executable => Paths.ruby_executable, :arguments => arguments
      end

      def chef_client_executable_path
        chef_gem.executables_path.join('chef-client')
      end

    end
  end
end

Biosphere::Managers.register Biosphere::Managers::Chefserver
