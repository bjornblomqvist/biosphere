require 'biosphere/managers/chef'
require 'biosphere/resources/gem'
require 'biosphere/resources/command'

module Biosphere
  module Managers
    class Chefserver < Chef

      private

      def chef_command
        env_vars = { 'GEM_HOME' => Resources::Gem.rubygems_path, 'BIOSPHERE_HOME' => BIOSPHERE_HOME }
        arguments = [chef_client_executable_path, '--config', chef_knife_config_path]
        arguments += ['--override-runlist', knife_config[:override_runlist]] if knife_config[:override_runlist]
        Resources::Command.new :show_output => true, :env_vars => env_vars, :executable => BIOSPHERE_RUBY_EXECUTABLE_PATH, :arguments => arguments
      end

      def chef_client_executable_path
        chef_gem.executables_path.join('chef-client')
      end

    end
  end
end

Biosphere::Manager.register Biosphere::Managers::Chefserver