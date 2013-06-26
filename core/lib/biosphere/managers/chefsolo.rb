require 'biosphere/managers/chef'
require 'biosphere/resources/gem'
require 'biosphere/resources/command'
require 'biosphere/resources/file'

module Biosphere
  module Managers
    class Chefsolo < Chef

      private

      def chef_command
        arguments = [chef_solo_executable_path, '--config', chef_knife_config_path, '--json-attributes', chef_json_path]
        Resources::Command.new :show_output => true, :indent => 4, :env_vars => default_env_vars, :executable => Paths.ruby_executable, :arguments => arguments
      end

      def ensure_knife_config
        super
        Resources::File.write chef_json_path, chef_json_template
      end

      def chef_json_template
        %{{ "run_list": "#{chef_run_list}" }}
      end

      def chef_run_list
        knife_config[:runlist] || "recipe[biosphere]"
      end

      def chef_solo_executable_path
        chef_gem.executables_path.join('chef-solo')
      end

      def knife_config_template
        result = super
        cookbook_path = Array(knife_config[:cookbook_path]).map { |path| File.expand_path(path) }
        result += %{\ncookbook_path %w{ #{cookbook_path.join(' ')} }}
      end

      def chef_json_path
        workdir_path.join('solo.json')
      end

    end
  end
end

Biosphere::Manager.register Biosphere::Managers::Chefsolo