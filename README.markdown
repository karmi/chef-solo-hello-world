Chef Solo Hello World
=====================

This repository contains a tutorial for [Chef Solo](http://wiki.opscode.com/display/chef/Chef+Solo).

It contains five steps which demonstrate the basics of Chef:

1. The simplest node configuration: install Nginx
3. Add a simple "website" for Nginx with the "application" cookbook
4. Use Ohai attributes in the Chef HTML template
5. Launch the machine on an Amazon EC2 instance

To work with the tutorial, you'll need:

* A working Ruby and Rubygems support
* [Vagrant](http://vagrantup.com) for [Virtual Box](https://www.virtualbox.org)
* [Git](http://git-scm.com)
* Optionally, the [Berkshelf](http://berkshelf.com) Rubygem


The simplest node configuration: install Nginx
----------------------------------------------

Start the tutorial with:

    rake start

First, launch the virtual machine with Vagrant:

    vagrant up

Then, download the required cookbooks, either with Berkshelf:

    berks install --path ./tmp/cookbooks

... or manually with `curl`:

    curl -# -L -k http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/2059/original/ohai.tgz | tar xz -C tmp/cookbooks
    curl -# -L -k http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1863/original/build-essential.tgz | tar xz -C tmp/cookbooks
    curl -# -L -k http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/1425/original/runit.tgz | tar xz -C tmp/cookbooks
    curl -# -L -k http://s3.amazonaws.com/community-files.opscode.com/cookbook_versions/tarballs/2056/original/nginx.tgz | tar xz -C tmp/cookbooks

Generate configuration for connecting to the machine via SSH:

    vagrant ssh-config > tmp/vagrant_ssh_config

Upload cookbooks, bootstrap script and node config

    HOST=webserver
    scp -F tmp/vagrant_ssh_config -r bootstrap.sh node*.json tmp/cookbooks $HOST:/tmp

Run the bootstrap script:

    time ssh -F tmp/vagrant_ssh_config -t $HOST "sudo bash /tmp/bootstrap.sh"

Run Chef in the _solo_ mode:

    time ssh -F tmp/vagrant_ssh_config -t $HOST "sudo chef-solo -j /tmp/node.json"

Nginx should be installed on the node. Check it:

    ssh $HOST -F tmp/vagrant_ssh_config -t "sudo service nginx status"
    ssh $HOST -F tmp/vagrant_ssh_config -t "nginx -v"
    ssh $HOST -F tmp/vagrant_ssh_config -t "curl localhost"

When you open the <http://33.33.33.33/> URL in your browser, you should see the Nginx 404 page.


Add a simple "website" for Nginx with the "application" cookbook
----------------------------------------------------------------

Let's add a simple "application" (a HTML page) for displaying with Nginx:

    rake next

The relevant resources are the recipe (`cookbooks/application/recipes/default.rb`),
Nginx configuration file (`cookbooks/application/templates/default/application.conf.erb`),
and the template (`cookbooks/application/templates/default/index.html.erb`).

Upload the "application" cookbook and update node configuration to the virtual machine:

    HOST=webserver
    scp -F tmp/vagrant_ssh_config -r node.json $HOST:/tmp
    scp -F tmp/vagrant_ssh_config -r cookbooks $HOST:/tmp

Run the bootstrap script:

    time ssh -F tmp/vagrant_ssh_config -t $HOST "sudo bash /tmp/bootstrap.sh"

Run Chef:

    time ssh -F tmp/vagrant_ssh_config -t $HOST "sudo chef-solo -j /tmp/node.json"

When you open the <http://33.33.33.33/> URL in your browser now, you should see
a simple HTML page.


Use Ohai attributes in the Chef HTML template
---------------------------------------------

One of the important Chef components is [Ohai](http://wiki.opscode.com/display/chef/Ohai),
a tool to gather and report information about the node, such as the operating system variant,
versions of software packages installed.

Chef templates are regular ERb (embedded Ruby) template, so we can fill in various node attributes gathered by Chef,
such as node name, Nginx version, etc:

    rake next

Upload the updated cookbook to host:

    HOST=webserver
    scp -F tmp/vagrant_ssh_config -r cookbooks $HOST:/tmp

Run the bootstrap script:

    time ssh -F tmp/vagrant_ssh_config -t $HOST "sudo bash /tmp/bootstrap.sh"

Run Chef:

    time ssh -F tmp/vagrant_ssh_config -t $HOST "sudo chef-solo -j /tmp/node.json"

When you open the <http://33.33.33.33/> URL in your browser now, you should see
a simple HTML page with information about the virtual machine (Ubuntu and Nginx versions).


Launch the machine on an Amazon EC2 instance
--------------------------------------------

Launching and provisioning the node inside a Vagrant virtual machine is convenient. But it's more fun to
have the machine running in the internet.

With a bit of configuration, Chef makes it equally easy to launch the node in the
[Amazon Elastic Compute Cloud (EC2)](http://aws.amazon.com/ec2/):

    rake next

First, we need to install the [`knife-ec2`](https://rubygems.org/gems/knife-ec2) gem
and provide it with some [AWS credentials](https://portal.aws.amazon.com/gp/aws/securityCredentials):

    gem install knife-ec2
    export AWS_ACCESS_KEY_ID=<your AWS access key>
    export AWS_SECRET_ACCESS_KEY=<your AWS secret access key>

Your SSH private key for accessing servers on EC2 should be present in (create it in the AWS console):

    ~/.ssh/<YOUR USERNAME>-ec2.pem

Run the following command to create and provision a virtual server:

    time knife ec2 server create --node-name webserver \
                                    --config knife.rb \
                                    --ssh-user ubuntu \
                                    --run-list 'recipe[nginx],recipe[application]' \
                                    --groups webserver \
                                    --template-file ./bootstrap_ec2.erb \
                                    --flavor t1.micro

The `knife-ec2` gem will launch the specified EC2 instance, based on [Ubuntu 12.04](https://cloud-images.ubuntu.com/precise/current/), install Chef and perform basic bootstrap (`bootstrap_ec2.erb`).

The bootstrap script will also download all required resources (cookbooks, node.json) and perform
a Chef run, provisioning the node as a webserver.

After the process is complete, open the _Public DNS Name_ URL in your web browser.

To terminate the server, run:

    knife ec2 server delete <Instance ID> --yes

----

(c) 2012 Karel Minarik & Vojtech Hyza. MIT License.
