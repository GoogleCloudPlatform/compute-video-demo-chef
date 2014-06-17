#!/bin/bash
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

# Assumes your chef-repo is in your $HOME directory and that the workstation
# has already been set up
CHEF_REPO=$HOME/chef-repo
DEMO_TMP=$CHEF_REPO/gce-demo-tmp

# location of this 'install.sh' script
mydir=$( cd $(dirname $0) ; pwd -P)

cp -R $mydir/cookbooks/chefconf2014 $CHEF_REPO/cookbooks
pushd $CHEF_REPO/cookbooks
# TODO(erjohnso): using 'tmp' branch until paulrossman fixes firewall
git clone -b tmp https://github.com/chef-partners/google-compute-engine gce
popd
cp $mydir/recipes/* $CHEF_REPO/cookbooks/gce/recipes
mkdir $DEMO_TMP

# Prompt user for auth and write config
echo -n "Enter your Service Account Client Email: "
read email
echo -n "Enter your Project ID: "
read project
echo -n "Enter the full path to your Service Account private key: "
read keypath


demo_config=$CHEF_REPO/cookbooks/gce/recipes/gce_auth.rb
echo "Writing your auth/demo settings to '$demo_config'"
echo "AUTH_EMAIL = \"$email\"" > $demo_config
echo "AUTH_PROJECT = \"$project\"" >> $demo_config
echo "AUTH_KEYPATH = \"$keypath\"" >> $demo_config
echo "CLIENT_RB = \"$DEMO_TMP/client_rb\"" >> $demo_config
echo "FIRST_BOOT = \"$DEMO_TMP/first_boot_json\"" >> $demo_config
echo "VALIDATION_PEM = \"$CHEF_REPO/.chef/chef-server-validation.pem\"" >> $demo_config


# Create the client_rb file
echo "log_level                :info" > $DEMO_TMP/client_rb
echo "log_location             STDOUT" >> $DEMO_TMP/client_rb
echo "validation_client_name   'chef-validator'" >> $DEMO_TMP/client_rb
echo "validation_key           '/etc/chef/validation.pem'" >> $DEMO_TMP/client_rb
grep chef_server_url $CHEF_REPO/.chef/knife.rb >> $DEMO_TMP/client_rb

# Create the first_boot_json file
echo "{\"run_list\":[\"chefconf2014\"]}" > $DEMO_TMP/first_boot_json

