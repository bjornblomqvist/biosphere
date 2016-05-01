require 'biosphere/resources/command'

module Biosphere
  module Managers
    module Chefsolos
      class RemoteCookbooks

        def initialize(sphere: nil, config: nil)
          @sphere = sphere
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

        attr_reader :sphere, :config

        def call!
          path.exist? ? update : clone
        end

        def path
          sphere.path.join('cookbooks').join repo_name
        end

        def repo_name
          File.basename config.cookbooks_repo.to_s.split('/')[-2..-1].join('_'), '.*'
        end

        def clone
          Log.info { "Cloning remote cookbooks from #{config.cookbooks_repo}" }
          Log.info { "Cloning into #{path}" }

          if clone_command.call.success?
            Log.debug { 'Successfully cloned remote cookbooks.' }
          else
            Log.separator
            Log.error { 'Failed to clone remote cookbooks. Use the --debug flag for more details.'.red }
            Log.separator
            raise Errors::CouldNotCloneRemoteCookbooks
          end
        end

        def clone_command
          arguments = %W(clone #{config.cookbooks_repo} #{path})
          Resources::Command.new executable: :git, arguments: arguments
        end

        def update
          Log.info { "Updating remote cookbooks from #{config.cookbooks_repo}" }

          if update_command.call.success?
            Log.info { 'Cookbooks successfully updated.' }
          else
            Log.separator
            Log.error { 'Failed to update remote cookbooks. Use the --debug flag for more details.'.red }
            Log.separator
            raise Errors::CouldNotUpdateRemoteCookbooks
          end
        end

        def update_command
          arguments = %W(--work-tree #{path} --git-dir #{path.join('.git')} pull origin master)
          Resources::Command.new executable: :git, arguments: arguments
        end

      end
    end
  end
end
