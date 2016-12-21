#
# Cookbook Name:: jnj_logrotate
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
template '/etc/logrotate.conf' do
  owner 'root'
  group 'root'
  mode   0644
  source 'standalone.xml.erb'
end
