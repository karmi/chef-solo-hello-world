# To launch a clean Ubuntu 12.04 system in the virtual machine
# with [Vagrant](http://vagrantup.com), run:
#
#     vagrant up
#
# See <http://vagrantup.com/v1/docs/vagrantfile.html> for more info.
#
Vagrant::Config.run do |config|

  config.vm.define :webserver do |box_config|

    box_config.vm.box       = 'precise64'
    box_config.vm.box_url   = 'http://files.vagrantup.com/precise64.box'

    box_config.vm.host_name = 'webserver'

    box_config.vm.network   :hostonly, '33.33.33.33'

    box_config.vm.customize { |vm| vm.memory_size = 256 }

  end

end
