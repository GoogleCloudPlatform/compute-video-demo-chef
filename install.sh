#!/bin/bash

# Assumes your chef-repo is in your $HOME directory
CHEF_REPO=$HOME/chef-repo

# location of this 'install.sh' script
mydir=$( cd $(dirname $0) ; pwd -P)

cp -R $mydir/cookbooks/chef-demo $CHEF_REPO/chef-repo/cookbooks
pushd $CHEF_REPO/cookbooks
git clone https://github.com/chef-partners/google-compute-engine gce
popd
cp $mydir/recipes/* $CHEF_REPO/cookbooks/gce/recipes

# Prompt user for auth and write config
echo -n "Enter your Service Account Client Email: "
read email
echo -n "Enter your Project ID: "
read project
echo -n "Enter the full path to your Service Account private key: "
read keypath

auth_file=$CHEF_REPO/cookbooks/gce/recipes/gce_auth.rb
echo "Writing your auth settings to $auth_file"
echo "AUTH_EMAIL = \"$email\"" > $auth_file
echo "AUTH_PROJ = \"$project\"" >> $auth_file
echo "AUTH_KEY = \"$keypath\"" >> $auth_file
