# Copyright 2014 Google Inc. All rights reserved.
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
    first_boot_json FIRST_BOOT
    client_rb CLIENT_RB
    validation_pem VALIDATION_PEM
    # auth
    client_email AUTH_EMAIL
    project_id AUTH_PROJECT
    key_location AUTH_KEYPATH
    action :create
  end
  servers << "#{name_prefix}-#{i}"
end

gce_firewall "#{name_prefix}-allow-http" do
  network "default"
  allowed_ports [80]
  # auth
  client_email AUTH_EMAIL
  project_id AUTH_PROJECT
  key_location AUTH_KEYPATH
  action :create
end

gce_lb_healthcheck "#{name_prefix}-hc" do
  request_path "/"
  port 80
  # auth
  client_email AUTH_EMAIL
  project_id AUTH_PROJECT
  key_location AUTH_KEYPATH
  action :create
end

gce_lb_targetpool "#{name_prefix}-tp" do
  region "#{region}"
  instances servers
  health_checks ["#{name_prefix}-hc"]
  # auth
  client_email AUTH_EMAIL
  project_id AUTH_PROJECT
  key_location AUTH_KEYPATH
  action :create
end

gce_lb_forwardingrule "#{name_prefix}-fr" do
  region "#{region}"
  ip_protocol "TCP"
  port_range "80-8080"
  target_pool "#{name_prefix}-tp"
  # auth
  client_email AUTH_EMAIL
  project_id AUTH_PROJECT
  key_location AUTH_KEYPATH
  action :create
end
