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
        return unless cookbooks_repo
        if cookbooks_path && cookbooks_path.exist?
          update_cookbooks
        else
          clone_cookbooks
        end
      end

      def clone_cookbooks
        Log.info "Cloning remote cookbooks from #{cookbooks_repo}"
        Log.info "Cloning into #{cookbooks_repo_path}"
        result = Resources::Command.run :executable => 'git', :arguments => %W{ clone #{cookbooks_repo} #{cookbooks_repo_path} }
      end

      def update_cookbooks
        Log.info "Updating remote cookbooks from #{cookbooks_repo}"
        work_tree = cookbooks_repo_path
        git_dir = cookbooks_repo_path.join('.git')
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
        @cookbooks_repo ||= begin
          result = Pathname.new config.cookbooks_repo
          Log.debug "The remote cookbooks repository is located at #{result}"
          result
        end
      end

      def cookbooks_repo_name
        @cookbooks_repo_name ||= begin
          result = File.basename cookbooks_repo.to_s.split('/').last, '.*'
          Log.debug "The cookbooks repository name is #{result}"
          result
        end
      end

      def cookbooks_repo_path
        cookbooks_container_path.join cookbooks_repo_name
      end

      def cookbooks_path
        @cookbooks_path ||= begin
          paths = Array(knife_config[:cookbooks_path])
          Log.debug "sphere.yml specified the following cookbooks_path: #{paths.inspect}"
          if cookbooks_repo.to_s == ""
            paths = paths.map { |path| File.expand_path(path) }
            result = paths.join(' ')
          else
            result = cookbooks_repo_path.join paths.first
          end
          Log.debug "Using cookbooks located at #{result}"
          result
        end
      end

      def cookbooks_container_path
        @cookbooks_container_path ||= begin
          result = sphere.path.join('cookbooks')
          Log.debug "The cookbooks container is located at #{result}"
          result
        end
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
        result += %{\ncookbook_path %w{ #{cookbooks_path} }}
      end

      def chef_json_path
        workdir_path.join('solo.json')
      end

    end
  end
end

Biosphere::Manager.register Biosphere::Managers::Chefsolo