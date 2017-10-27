#
# Cookbook Name:: root_profile
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

# To Create a directory
directory '/root' do
  owner 'root'
  group 'root'
  mode '0550'
end

directory '/root/.histdir' do
  owner 'root'
  group 'root'
  mode '0755'
end

template '/root/.bashrc' do
  source '.bashrc.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/root/.bash_profile' do
  source '.bash_profile.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/root/.profile' do
  source '.profile.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/cron.d/histdir_cleanup' do
  source 'histdir_cleanup.erb'
  owner 'root'
  group 'root'
  mode '0644'
end
