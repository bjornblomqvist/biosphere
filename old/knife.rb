chef_path = File.expand_path(File.dirname(__FILE__))

def config(name)
  path = File.expand_path(%{../config/#{name.to_s}}, File.dirname(__FILE__))
  File.exists?(path) ? File.read(path).chomp : nil
end

chef_server_url config(:chef_server_url)
validation_key %{#{chef_path}/validation.pem}
client_key %{#{chef_path}/client_keys/#{config(:chef_node_name)}.pem}
file_cache_path  %{#{chef_path}/cache}
file_backup_path %{#{chef_path}/cache/backups}
cache_options({ :path => %{#{chef_path}/cache/checksums}})
node_name config(:chef_node_name)
