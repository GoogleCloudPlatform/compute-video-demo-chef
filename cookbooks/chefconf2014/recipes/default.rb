#
# Cookbook Name:: chefconf2014
# Recipe:: default
#
# Copyright 2014, Google
#
# All rights reserved - Do Not Redistribute
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

