#
# Cookbook Name:: rsyslog
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# file '/etc/rsyslog.d/al_log_agt.conf' do
#   mode '0755'
#   owner 'root'
#   group 'root'
#   content IO.read('/etc/rsyslog.d/al_log_agt.conf')
#   action :create
#   notifies :run, 'service[rsyslog]', :immediately
# end
# @LogServer = node['jnj_rsyslog']['ipaddress']

template '/etc/rsyslog.d/al_log_agt.conf' do
  source 'al_log_agt.erb'
  mode '0644'
  notifies :restart, 'service[rsyslog]', :immediately
end

service 'rsyslog' do
  action [:enable, :start]
end
