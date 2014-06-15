

# Do a little trickery to make sure the Gogle Auth credentials
# can be loaded in without having to askt he user to hand-edit
# a file.  The 'gce_auth.rb' file is auto-geerated from the
# demo repo 'install.sh' script
my_dir = ::File.expand_path(::File.dirname(__FILE__))
require "#{my_dir}/gce_auth"
sa_email = AUTH_EMAIL
sa_proj = AUTH_PROJECT
sa_key = AUTH_KEYPATH

name_prefix="chef-demo"
region = "us-central1"
zone_a = "#{region}-a"
zone_b = "#{region}-b"
servers = []

(1..4).each do |i|
  gce_instance "#{name_prefix}-#{i}" do
    machine_type "n1-standard-1"
    if i % 2 == 0
      zone_name "#{zone_a}"
    else
      zone_name "#{zone_b}"
    end
    boot_disk_image "debian-7-wheezy-v20140408"
    service_account_scopes ["compute", "userinfo.email", "devstorage.full_control"]
    tags ["chefconf2014"]
    metadata "demo"=>"chefconf2014", "foo"=>"bar"
    auto_restart true
    on_host_maintenance "TERMINATE"
    # enable turbo mode!
    wait_for false
    # bootstrap attributes
    first_boot_json "/home/erjohnso/first_boot_json"
    client_rb "/home/erjohnso/client_rb"
    validation_pem "/home/erjohnso/chef-repo/.chef/chef-server-validation.pem"
    # auth
    project_id "#{sa_proj}"
    client_email "#{sa_email}"
    key_location "#{sa_key}"
    action :create
  end
  servers << "#{name_prefix}-#{i}"
end

gce_firewall "#{name_prefix}-allow-http" do
  network "default"
  allowed_ports [80]
  # auth
  project_id "#{sa_proj}"
  client_email "#{sa_email}"
  key_location "#{sa_key}"
  action :create
end

gce_lb_healthcheck "#{name_prefix}-hc" do
  request_path "/"
  port 80
  # auth
  project_id "#{sa_proj}"
  client_email "#{sa_email}"
  key_location "#{sa_key}"
  action :create
end

gce_lb_targetpool "#{name_prefix}-tp" do
  region "#{region}"
  instances servers
  health_checks ["#{name_prefix}-hc"]
  # auth
  project_id "#{sa_proj}"
  client_email "#{sa_email}"
  key_location "#{sa_key}"
  action :create
end

gce_lb_forwardingrule "#{name_prefix}-fr" do
  region "#{region}"
  ip_protocol "TCP"
  port_range "80-8080"
  target_pool "#{name_prefix}-tp"
  # auth
  project_id "#{sa_proj}"
  client_email "#{sa_email}"
  key_location "#{sa_key}"
  action :create
end
