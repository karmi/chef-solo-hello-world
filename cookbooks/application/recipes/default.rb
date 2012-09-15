# Create the "application" Nginx configuration file
#
template "#{node[:nginx][:dir]}/conf.d/application.conf" do
  source "application.conf.erb"
  owner 'root' and mode 0644

  notifies :restart, resources(:service => "nginx")
end

# Create the "application" directory
#
directory node[:application][:dir] do
  owner node[:nginx][:user] and group node[:nginx][:user] and mode 0775
  recursive true

  action :create
end

# Create the "application" page
#
template "#{node[:application][:dir]}/index.html" do
  source "index.html.erb"
  owner node[:nginx][:user] and group node[:nginx][:user] and mode 0775

  action :create
end
