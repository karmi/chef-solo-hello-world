include_attribute 'nginx'

default[:application][:dir] = "#{node[:nginx][:root]}/application"
