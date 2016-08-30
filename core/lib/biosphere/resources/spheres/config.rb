module Biosphere
  module Resources
    module Spheres
      module Config

        def self.template
          <<-END.undent
            # In this YAML file you can configure how this sphere is updated.
            # To manage this file manually, simply leave this file empty or delete it.
            #
            # This is an example setup, see https://github.com/halo/spheres/tree/master/example

            manager:
              chefsolo:
                cookbooks_repo: https://github.com/halo/spheres.git
                cookbooks_repo_subdir: example

                # You can change the default run-list here:
                # runlist: "recipe[biosphere]"

                # You can add custom ENV variables here:
                # env_vars:
                #   nginx_port: 8080
                #   github_ssh_key_name: my_custom_ssh_key
          END
        end

      end
    end
  end
end
