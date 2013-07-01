require 'uri'
require 'biosphere/managers/chef'
require 'biosphere/resources/gem'
require 'biosphere/resources/command'
require 'biosphere/resources/file'

module Biosphere
  module Errors
    class CouldNotUpdateRemoteCookbooks < Error
      def code() 67 end
    end
  end
end


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
        ensure_cookbooks
        Resources::File.write chef_json_path, chef_json_template
      end

      def ensure_cookbooks
        if cookbooks_path && cookbooks_path.exist?
          update_cookbooks
        else
          clone_cookbooks
        end
      end

      def clone_cookbooks
        Log.info "Cloning remote cookbooks from #{cookbooks_repo}"
        Log.info "Cloning into #{cookbooks_path}"
        result = Resources::Command.run :executable => 'git', :arguments => %W{ clone #{cookbooks_repo} #{cookbooks_path} }
      end

      def update_cookbooks
        Log.info "Updating remote cookbooks from #{cookbooks_repo}"
        work_tree = cookbooks_path
        git_dir = cookbooks_path.join('.git')
        result = Resources::Command.run :executable => 'git', :arguments => %W{ --work-tree #{work_tree} --git-dir #{git_dir} pull origin master }
        if result.success?
          Log.info "Cookbooks were updated."
        else
          message = "Could not update cookbooks: #{result.stdout.strip} #{result.stderr.strip}"
          Log.error message
          raise Errors::CouldNotUpdateRemoteCookbooks, message
        end
      end

      def cookbooks_repo
        return unless config.cookbooks_repo
        Pathname.new config.cookbooks_repo
      end

      def cookbooks_path
        return unless cookbooks_repo
        name = File.basename cookbooks_repo.to_s.split('/').last, '.*'
        cookbooks_container_path.join name
      end

      def cookbooks_container_path
        sphere.path.join('cookbooks')
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
        paths = Array(knife_config[:cookbooks_path])
        if cookbooks_repo.to_s == ""
          paths = paths.map { |path| File.expand_path(path) }
          result += %{\ncookbook_path %w{ #{paths.join(' ')} }}
        else
          if path = paths.first
            path = cookbooks_path.join(path)
            Log.debug "Using cookbooks located at relative path #{path}"
            result += %{\ncookbook_path %w{ #{path} }}
          else
            Log.debug "Using cookbooks located at absolute path#{cookbooks_path}"
            result += %{\ncookbook_path %w{ #{cookbooks_path} }}
          end
        end
      end

      def chef_json_path
        workdir_path.join('solo.json')
      end

    end
  end
end

Biosphere::Manager.register Biosphere::Managers::Chefsolo