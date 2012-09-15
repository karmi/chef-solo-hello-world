R=`which ruby` || R='/opt/vagrant_ruby/bin/ruby'

test -x $R && $R -e 'File.mtime("/var/lib/apt/lists/partial/") < Time.now - 3600 ? exit(1) : exit(0)' > /dev/null  2>&1 || \
  (
  # Update packages
  #
  echo '-- Updating packages ---------';
  apt-get update --quiet --yes && \
  #
  # Install curl and vim
  #
  echo '-- Installing curl and vim ---';
  apt-get install curl vim --quiet --yes
  )

test -d "/opt/chef" || \
  (
  # Install Chef ("omnibus")
  #
  echo '-- Installing Chef -----------';
  curl -# -L http://www.opscode.com/chef/install.sh | bash
  )

# Create neccessary Chef resources and configs
#
echo '-- Copying cookbooks and configs'
mkdir -p /tmp/cookbooks /tmp/site-cookbooks
mkdir -p /var/chef/site-cookbooks /var/chef/cookbooks /etc/chef
touch /etc/chef/solo.rb

# Copy cookbooks from /tmp
#
cp -r /tmp/cookbooks/* /var/chef/cookbooks

echo "== Bootstrap done ======="; echo
