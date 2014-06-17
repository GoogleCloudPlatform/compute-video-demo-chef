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
