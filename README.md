## compute-video-demo-chef

This is the supporting documentation for the demo video,
<a href='https://www.youtube.com/watch?v=6K2biJbVV8o'>Using Chef with Google</a>.

The goal of this repository is to provide the extra detail necessary for
you to completely replicate the recorded demos. The video's main goal
is to show quick, fully working demos without bogging you down with all
of the required details allowing you to see the "Good Stuff".

1. The first demo will show you how you can use
<a href='https://docs.chef.io/plugin_knife_google.html'>knife-google</a>
to create a Compute Engine instance and bootstrap it.

2. The second demo will show how to use the
<a href='https://github.com/chef-partners/google-compute-engine'>Google Compute Engine LWRP</a>
to automate:
 * Creating 4 Compute Engine instances
 * Installing the Apache web server on each and enabling `mod_headers`
 * Using Ohai and a template to create a custom site page
 * Allowing HTTP traffic to the instances with a custom firewall rule
 * Creating a Compute Engine Load-balancer to distribute traffic over the 4 instances

These are intended to be a fairly trival examples. The video and repo show off
the integration between Chef and Google Compute Engine. This can be the
foundation for building more real-world configurations.

### Overview

To fully replicate these demos, you will be setting up the Open Source Chef
Server and a Chef Workstation in your Compute Engine project. Both the
Chef Server and Chef Client can be downloaded from the
[Chef Install page](http://www.getchef.com/chef/install/).

The LWRP demo will be performed by applying a Chef recipe utilizing
[Chef Zero](http://www.getchef.com/blog/2013/10/31/chef-client-z-from-zero-to-chef-in-8-5-seconds/)
from your Chef Workstation. The four Compute Engine instances will be
bootstrapped into your Chef Server's environment, so even though the demo
uses Chef Zero, you will still be able to manage the nodes with your Chef
Server.

The node bootstrapping is accomplished by passing in Chef configuration and
authorization files when the instances are created. Once these files are in
place and the instance boots, a custom startup script (see Compute Engine's
[startup scripts](https://developers.google.com/compute/docs/howtos/startupscript))
invokes the first `chef-client` run on the instance. Since the new instance
has the proper authorization, it checks in with the Chef Server and becomes
a managed node. An initial `run_list` is also provided that applies a demo
cookbook.

However, it is not strictly necessary to run a Chef Server to demonstrate the
[Compute Engine LWRP](https://github.com/chef-partners/google-compute-engine).
It is possible to use the LWRP to manage all Compute Engine resources such
as networks, load-balancers, instances, etc. New instances do not strictly
need to be bootstrapped into your Chef enrionment. If you exclude the special
instance attributes `validation_pem`, `client_rb`, and `first_boot_json`
from your recipe, the new instances will not identify themselves with a
Chef server.

This demo will assume that you *are* using a Chef Server. Therefore, the
special instance attributes in the demo recipe will be set.

## Google Cloud Platform Project

1. You will need to create a Google Cloud Platform Project as a first step.
Make sure you are logged in to your Google Account (gmail, Google+, etc) and
point your browser to https://console.developers.google.com/. You should see a
page asking you to create your first Project.

1. When creating a Project, you will see a pop-up dialog box. You can specify
custom names but the *Project ID* is globally unique across all Google Cloud
Platform customers.

1. It's OK to create a Project first, but you will need to set up billing
before you can create any virtual machines with Compute Engine. Look for the
*Billing* link in the left-hand navigation bar.

1. In order for duplicate this demo, you'll need a
[Service Account](https://developers.google.com/console/help/#service_accounts)
for the appropriate authorization. You may use the existing default Service
Account, or you can create a new one.  If you create a new one, navigate to
*APIs &amp; auth -&gt; Credentials* and under the OAuth section,
*Create New Client ID*. Make sure to select *Service Account*. Download the
*P12 key* and save the file. The passphrase for the P12 key is *notasecret*.
Also make sure to record the *Email address* that ends with
`@developer.gserviceaccount.com` since this will be required in your Chef
recipes.

1. Next you will want to install the [Cloud SDK](https://developers.google.com/cloud/sdk/)
and make sure you've successfully authenticated and set your default project ID
as instructed.

1. Before continuing, make sure to record the following information that will
be required when configuring the demo:
 * Your Google Cloud Platform *Project ID*
 * The Service Account *Client ID* email address (ends with
   `@developer.gserviceaccount.com`)
 * The full pathname to the corresponding private P12 key file

## Required Compute Engine instances

To replicate this demo, you will need to create two Compute Engine instances.
You can either create an instance in the
[Developers Console](https://console.developers.google.com/) or with the
`gcloud compute` commmand-line utility. In the sections below, there will be
information about the specified operating system image to use and other
instance parameters.

* Developers Console: If you use this method, select the left-hand
  navigation menu item for *Compute* and sub-menu *Compute Engine*. In the
  sub-menu, click on the *VM Instances* option and look for a button labeled
  *New instnace*. The resulting page will provide all necessary options for
  creating a new Compute Engine instance.

* `gcloud compute`: With this method, you must make sure to specify the
   appropriate instance parameters to the command. The demo assumes you will
   use this method for creating the Server and Workstation.

## Scopes / Authorization

When creating Compute Engine instances, this demo assumes you will specify the
authorization scopes for full control of Google Cloud Storage and read-write
access to Compute Engine.

## Chef Server

1. Create the Compute Engine instance
    ```
    # Make sure to use the CentOS 6 image for this demo
    gcloud compute instances create chef-server --image centos-6 --zone us-central1-b --machine-type n1-standard-1 --scopes compute-rw,storage-full
    ```

1. SSH to your chef server and then become root
    ```
    gcloud compute ssh chef-server --zone us-central1-b
    sudo -i
    ```

1. Update your system packages
    ```
    yum update
    ```

1. [Download](https://downloads.chef.io/chef-server) the Chef Server. Select
*Enterprise Linux, Version 6, x86_64* and the latest version. The page
should provide a link to the RPM package that you can use to copy/paste
in your terminal for download. For example,
    ```
    wget https://web-dl.packagecloud.io/chef/stable/packages/el/6/chef-server-11.1.7-1.el6.x86_64.rpm
    ```

1. Install the package
    ```
    rpm -i chef-server-11.1.7-1.el6.x86_64.rpm
    ```

1. Reconfigure the Chef Server as indicated on the download page
    ```
    chef-server-ctl reconfigure
    ```

1. As instructed on Chef's
[documentation](http://docs.chef.io/open_source/)
the first thing you should do is login and change the default `admin` console
password. In order to access the web console, you will need to create a
firewall rule to allow HTTPS (port 443) traffic.  Once that is done, point
your browser to your Chef Server's public IP (e.g. https://public-ip:443/)
and log in with user `admin` and password `p@ssw0rd1`. Once logged in,
immediately change the `admin` user's password. You can find your Chef
Server's public IP in the Developers Console, or with,
   ```
   exit # to quit the 'root' user session
   gcloud compute firewall-rules create allow-https --allow=tcp:443
   gcloud compute instances get $(hostname -s) | grep natIP | awk '{print $2}'
   ```

## Chef Workstation

Now that you have set up the Chef Server, you can proceed to setting up the
Chef Workstation.  This is the machine that you, as the Chef administrator,
will use to develop cookbooks and manage your Chef environment.

1. Create the Compute Engine instance, this time specify a Debian 7 instance,
    ```
    # Make sure to use the Debian 7 image for this demo
    gcloud compute instances create chef-workstation --image debian-7 --zone us-central1-b --machine-type n1-standard-1 --scopes compute-rw,storage-full
    ```

1. SSH to your Chef Workstation
    ```
    gcloud compute ssh chef-workstation --zone us-central1-b
    ```

1. Update your system packages and install dependencies.
    ```
    sudo apt-get update
    sudo apt-get install git build-essential -y
    ```

1. Install Chef using the latest 11.x package from their page, e.g:
    ```
    wget https://opscode-omnibus-packages.s3.amazonaws.com/debian/6/x86_64/chef_11.18.12-1_amd64.deb
    dpkg -i chef_11.18.12-1_amd64.deb
    ```

1. The next few steps are derived from following the Chef Workstation
[installation instructions](http://docs.chef.io/open_source/install_workstation.html)
When finished, you should have a copy of the Chef Server's "validation" PEM
file, it's `admin.pem` file, and a `knife.rb` file that allows you to
interact with the Chef Server.

1. Create and set up the `chef-repo`
    ```
    cd $HOME
    git clone git://github.com/opscode/chef-repo.git
    mkdir chef-repo/.chef
    echo ".chef" >> chef-repo/.gitignore
    ```

1. Copy the Chef Server's validation PEM file
(`/etc/chef-server/chef-validator.pem`) to the workstation and save it to
`$HOME/chef-repo/.chef/chef-server-validation.pem`.

1. Similarly, copy the Chef Server's admin PEM file
(`/etc/chef-server/admin.pem`) to the workstation and save it to
`$HOME/chef-repo/.chef/admin.pem`.

1. Configure your knife utility. This will prompt you for several configuration
settings. Note that when specifying the Chef server URL, make sure to use the
public IP address rather than the default FQDN.  Unless you do some work work
to ensure the FQDN resolves to the public IP, your knife command will not be
able to resolve the name.  Below is a slightly modifed (defaults were removed)
example of the set up process,
    ```
    knife configure -i
    ```
   The session should look similar to,
    ```
    WARNING: No knife configuration file found
    Where should I put the config file? ~/chef-repo/.chef/knife.rb
    Please enter the chef server URL: https://107.178.0.1:443
    Please enter a name for the new user: erjohnso
    Please enter the existing admin name: admin
    Please enter the location of the existing admin's private key: ~/chef-repo/.chef/admin.pem
    Please enter the validation clientname: chef-validator
    Please enter the location of the validation key: ~/chef-repo/.chef/chef-server-validation.pem
    Please enter the path to a chef repository (or leave blank): ~/chef-repo
    Creating initial API user...
    Please enter a password for the new user: xxxxxxxx
    Created user[erjohnso]
    Configuration file written to /home/erjohnso/chef-repo/.chef/knife.rb
    ```

1. You can verify that your workstation has access to the Chef Server by
using the knife command to query the server. This command should show
you some information about one of the configured clients on the server,
    ```
    knife client show chef-webui
    ```
   The out put should look similar to,
    ```
    admin:      true
    chef_type:  client
    json_class: Chef::ApiClient
    name:       chef-webui
    public_key: xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    validator:  false
    ```

## Knife Demo

A common way to manage nodes with Chef is to use the `knife` utility.
With the [`knife-google`](http://docs.opscode.com/plugin_knife_google.html)
plugin, you can provision and bootstrap new Compute Engine instances.

This screencast, http://asciinema.org/a/10292, assumes you already have a
working Chef Server, Chef Workstation, and configured knife utility.

### Install and Setup

1. When you first created the Chef Workstation, you set the OAuth scopes to
allow the workstation to create other Compute Engine instances. In order
to ensure Workstation user account can access new instances, you'll want to
make sure to have created SSH keys and added them to your project metadata.
If you use the `gcloud compute` command to SSH back into itself, it will
prompt you to create a Compute Engine SSH keypair and upload it to the
metadata service. After logging in, log back out and continue to the next
step.
    ```
    gcloud compute ssh $(hostname -s)
    ```

1. Install the knife-google plugin on your Chef Workstation with,
    ```
    sudo /opt/chef/embedded/bin/gem install knife-google
    ```

1. You will need to create a Google Cloud Platform *Client ID for native
application* and use the *Client ID* (string ending with
`apps.googleusercontent.com`) and *Client secret*. Set up the knife-google
authorization with,
    ```
    knife google setup
    ```

### Demo

1. Once setup, you can then use knife-google to create and bootstrap a new
node with,
    ```
    knife google server create knife-test -m n1-standard-1 -I debian-7-wheezy-v20150423 -Z us-central1-b -i ~/.ssh/google_compute_engine -x $USER
    ```

1. Once the instance is created and the node registered with the Chef Server,
you can use standard knife commands to query the Chef Server for more details,
    ```
    knife node list                    # should show 'knife-test' listed
    knife node show knife-test -a gce  # Ohai hints for Compute Engine
    ```

1. The server can be deleted with knife also (the `-P` will also remove
the node reference from your Chef Server).  Note that the instances disk
will *not* be deleted.  You can use the `knife google disk` operations to
manage disks.
    ```
    knife google server delete knife-testing -Z us-central1-b -P
    # knife google disk delete knife-testing -Z us-central1-b
    ```

## Cookbook and Demo setup

The next two sections were recorded in a terminal screencast availble for
viewing at https://asciinema.org/a/10332.

1. Log into the Chef Workstation and install the ruby gem dependencies
required to use the
[Compute Engine LWRP](https://github.com/chef-partners/google-compute-engine),
    ```
    sudo /opt/chef/embedded/bin/gem install google-api-client --no-rdoc --no-ri
    sudo /opt/chef/embedded/bin/gem install fog --no-rdoc --no-ri
    ```

1. Check out this repositroy so that you can use pre-canned configuration
and demo files.
    ```
    cd $HOME
    git clone https://github.com/GoogleCloudPlatform/compute-video-demo-chef
    ```

1. Use the included `install.sh` script to copy the necessary files to run
the demo. The script will also prompt you for your Service Account
*Client Email*, *Project ID* and the full path to your *Private Key*,
    ```
    cd compute-vide-demo-chef
    ./install.sh
    ```

1. Since the demo uses Apache on Debian virtual machines, you'll need to
install a few community cookbook dependencies. You can do that with the
`knife` utility,
    ```
    cd ~/chef-repo
    knife cookbook site install apt
    knife cookbook site install apache2
    ```

1. The install script also created a demo cookbook based on the demo given
at [ChefConf2014](http://www.youtube.com/watch?v=D2OICR18zIo). You can upload
this demo cookbook to your Chef server along wth its cookbook dependencies
with,
    ```
    knife cookbook upload chefconf2014 --include-dependencies
    ```

## Demo time!

You've now completed all of the necessary setup to replicate the demo as
shown on the video. Now, you'll use LWRP to create and bootstrap the managed
instances, install Apache, and set up a Compute Engine load-balancer.

1. You should be logged into the Chef Workstation and in your Chef directory,
    ```
    cd $HOME/chef-repo
    ```

1. Next, you'll use *Chef Zero* to apply the demo recipe,
    ```
    chef-client -z -o 'gce::gce-demo'
    ```

1. Ok, let's test it out! Put the public IP address of your load-balancer into
your browser and take a look at the result. Within a few seconds you should
start to see a flicker of pages that will randomly bounce across each of your
instances. You can find the public IP address of your load-balancer in the
Developers Console, or with,
    ```
    gcloud compute forwarding-rules get chef-demo-fr | grep IPAddress | awk '{print $2}'
    ```

## All done!

That's it for the demos. You just used both the `knife-google` plugin and the
Google Compute Engine LWRP to create a complete environment consisting of
virtual machines (managed by Chef), persistent disks, firewall rule, and a
load-balancer.

## Cleaning up

When you're done with the demo, make sure to tear down all of your instances,
disks, and other resources. You will be charged for this usage and you will
accumulate additional charges if you do not remove these resources.

Fortunately, there is an included recipe for deleting all of the Compute
Engine resources created during the demo.  Simply use Chef Zero again with
the clean-up recipe,

```
chef-client -z -o 'gce::clean-up-demo'
```

If you also wish to remove the node references in your Chef Server, you can use
either use the Chef Web Console, or the knife utility from your Workstation,

```
knife node bulk delete "chef-demo*"
knife client bulk delete "chef-demo*"
```

## Contributing

Have a patch that will benefit this project? Awesome! Follow these steps to have it accepted.

1. Please sign our [Contributor License Agreement](CONTRIB.md).
1. Fork this Git repository and make your changes.
1. Create a Pull Request
1. Incorporate review feedback to your changes.
1. Accepted!

## License
All files in this repository are under the
[Apache License, Version 2.0](LICENSE) unless noted otherwise.

