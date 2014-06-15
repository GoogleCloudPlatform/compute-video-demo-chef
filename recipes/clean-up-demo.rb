

# Do a little trickery to make sure the Gogle Auth credentials
# can be loaded in without having to askt he user to hand-edit
# a file.  The 'gce_auth.rb' file is auto-geerated from the
# demo repo 'install.sh' script
my_dir = ::File.expand_path(::File.dirname(__FILE__))
require "#{my_dir}/gce_auth"

name_prefix="chef-demo"
region = "us-central1"
zone_a = "#{region}-a"
zone_b = "#{region}-b"

gce_lb_forwardingrule "#{name_prefix}-fr" do
  region "#{region}"
  # auth
  client_email AUTH_EMAIL
  project_id AUTH_PROJECT
  key_location AUTH_KEYPATH
  action :delete
end

gce_lb_targetpool "#{name_prefix}-tp" do
  region "#{region}"
  # auth
  client_email AUTH_EMAIL
  project_id AUTH_PROJECT
  key_location AUTH_KEYPATH
  action :delete
end

(1..4).each do |i|
  gce_instance "#{name_prefix}-#{i}" do
    if i % 2 == 0
      zone_name "#{zone_a}"
    else
      zone_name "#{zone_b}"
    end
    # auth
    client_email AUTH_EMAIL
    project_id AUTH_PROJECT
    key_location AUTH_KEYPATH
    action :delete
  end
end

gce_lb_healthcheck "#{name_prefix}-hc" do
  # auth
  client_email AUTH_EMAIL
  project_id AUTH_PROJECT
  key_location AUTH_KEYPATH
  action :delete
end

gce_firewall "#{name_prefix}-allow-http" do
  network "default"
  allowed_ports [80]
  # auth
  client_email AUTH_EMAIL
  project_id AUTH_PROJECT
  key_location AUTH_KEYPATH
  action :delete
end

(1..4).each do |i|
  gce_disk "#{name_prefix}-#{i}" do
    if i % 2 == 0
      zone_name "#{zone_a}"
    else
      zone_name "#{zone_b}"
    end
    # auth
    client_email AUTH_EMAIL
    project_id AUTH_PROJECT
    key_location AUTH_KEYPATH
    action :delete
  end
end
