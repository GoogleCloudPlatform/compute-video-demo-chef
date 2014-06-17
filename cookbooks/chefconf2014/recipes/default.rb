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
#
# Cookbook Name:: chefconf2014
# Recipe:: default
#
#

# Install apt
package "apt" do
  action :install
end

# Install apache2
package "apache2" do
  action :install
end

include_recipe "apache2"
include_recipe "apache2::mod_headers"

# start the service and ensure it starts on reboot
service "apache2" do
  action [:start, :enable]
end

# write out home page
template "/var/www/index.html" do
  source "index.html.erb"
  mode 0644
end

# install custom apache2.conf
cookbook_file "/etc/apache2/apache2.conf" do
  source "apache2.conf"
  mode 0644
end

