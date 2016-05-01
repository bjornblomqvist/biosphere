module Biosphere
  module Managers
    module Chefsolos
      class RemoteCookbooks

        def initialize(config: nil)
          @config = config
        end

        def call
          if config.cookbooks_repo.to_s == ''
            Log.debug { 'Your sphere.yml does not specify `cookbooks_repo:` so there are no remote cookbooks to sync with.' }
            return
          end
          call!
        end

        private

        def deprecations
          return if config.cookbooks_path.to_s == ''
          return if Pathname.new(config.cookbooks_path).absolute?
          Log.error { 'Your sphere.yml cannot specify both `cookbooks_repo:` and `cookbooks_path:`'.red }
          Log.error { 'Please rename `cookbooks_path:` to `cookbooks_repo_subdir:`'.red }
          raise Errors::SphereConfigDeprecation
        end


        def call!
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

        private

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


      end
    end
  end
end
