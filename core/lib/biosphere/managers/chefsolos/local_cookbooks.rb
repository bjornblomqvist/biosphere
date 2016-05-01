module Biosphere
  module Managers
    module Chefsolos
      class LocalCookbooks

        def initialize(sphere: nil, config: nil)
          @sphere = sphere
          @config = config
        end

        def call
          unless applicable?
            Log.debug { 'Your sphere.yml does not specify `cookbooks_path:` so there are no local cookbooks to use.' }
            return
          end
          deprecations
          call!
        end

        def path
          return unless applicable?
          Pathname.new config.cookbooks_path
        end

        private

        attr_reader :sphere, :config

        def applicable?
          config.cookbooks_path.to_s != ''
        end

        def deprecations
          return if config.cookbooks_path.to_s == ''
          return if Pathname.new(config.cookbooks_path).absolute?
          Log.error { 'Your sphere.yml cannot specify both `cookbooks_repo:` and `cookbooks_path:`'.red }
          Log.error { 'Please rename `cookbooks_path:` to `cookbooks_repo_subdir:`'.red }
          raise Errors::SphereConfigDeprecation
        end

        def call!
          if path.exist?
            Log.info { "Using local cookbooks at #{path}..." }
          else
            Log.error { 'The `cookbooks_path:` you specified in your sphere.yml does not exist.'.red }
            Log.error { "Please verify that #{path.to_s.inspect} is correct.".red }
            raise Errors::LocalCookbooksNotFound
          end
        end

      end
    end
  end
end
