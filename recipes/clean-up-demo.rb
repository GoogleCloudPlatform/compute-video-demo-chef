

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

gce_lb_forwardingrule "#{name_prefix}-fr" do
  region "#{region}"
  # auth
  project_id "#{sa_proj}"
  client_email "#{sa_email}"
  key_location "#{sa_key}"
  action :delete
end

gce_lb_targetpool "#{name_prefix}-tp" do
  region "#{region}"
  # auth
  project_id "#{sa_proj}"
  client_email "#{sa_email}"
  key_location "#{sa_key}"
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
    project_id "#{sa_proj}"
    client_email "#{sa_email}"
    key_location "#{sa_key}"
    action :delete
  end
end

gce_lb_healthcheck "#{name_prefix}-hc" do
  # auth
  project_id "#{sa_proj}"
  client_email "#{sa_email}"
  key_location "#{sa_key}"
  action :delete
end

gce_firewall "#{name_prefix}-allow-http" do
  network "default"
  allowed_ports [80]
  # auth
  project_id "#{sa_proj}"
  client_email "#{sa_email}"
  key_location "#{sa_key}"
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
    project_id "#{sa_proj}"
    client_email "#{sa_email}"
    key_location "#{sa_key}"
    action :delete
  end
end
