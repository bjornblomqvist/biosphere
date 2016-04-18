module Biosphere
  module Resources
    module Spheres
      module Config

        def self.template
          <<-END.undent
            # In this YAML file you can configure how this sphere is updated.
            # To manage this file manually, simply leave this file empty or delete it.
            #
            # To have a chef server manage this sphere, uncomment the following lines.
            # They are essentialy passed on to knife, see http://docs.opscode.com/config_rb_client.html
            # Important: Make sure that the validation.pem key is located inside the sphere directory!
            #            Alternatively you can specify the "validation_key_path" option to specify the path.
            #
            # manager:
            #   chefserver:
            #     chef_server_url: https://chefserver.example.com
            #     node_name: bobs_macbook.biosphere
            #     env_vars:
            #       ssh_key_name: id_rsa
            #     # override_runlist: "role[biosphere]"  # Uncomment this one to override the runlist assigned to you by the chef server.
            #
            # This following one uses chef-solo.
            # It has pretty much the same options as chefserver (except validation_key, chef_server_url, and override_runlist)
            #
            # manager:
            #   chefsolo:
            #     cookbooks_path: "~/Documents/my_cookbooks"
            #     # runlist: "recipe[biosphere]"  # Uncomment this line to change the default run list
            #
          END
        end

      end
    end
  end
end
