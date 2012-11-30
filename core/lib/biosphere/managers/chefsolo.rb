require 'biosphere/managers/chef'
require 'biosphere/resources/gem'
require 'biosphere/resources/command'

module Biosphere
  module Managers
    class Chefsolo < Chef

      private

      def chef_command
        env_vars = { 'GEM_HOME' => Resources::Gem.rubygems_path, 'BIOSPHERE_HOME' => BIOSPHERE_HOME }
        arguments = [chef_solo_executable_path, '--config', chef_knife_config_path, '--json-attributes', chef_json_path]
        Resources::Command.new :show_output => true, :env_vars => env_vars, :executable => BIOSPHERE_RUBY_EXECUTABLE_PATH, :arguments => arguments
      end

      def chef_solo_executable_path
        chef_gem.executables_path.join('chef-solo')
      end

      def knife_config_template
        super += %{cookbook_path "#{knife_config[:cookbook_path]}"}
      end

      def chef_json_path
        workdir_path.join('solo.json')
      end

    end
  end
end

Biosphere::Manager.register Biosphere::Managers::Chefsolo