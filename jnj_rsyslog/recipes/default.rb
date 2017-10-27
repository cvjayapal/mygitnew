#
# Cookbook Name:: jnj_rsyslog
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
template '/etc/rsyslog.d/al_log_agt.conf' do
  source 'al_log_agt.erb'
  mode '0644'
  variables(LogServer: node[:log][:server])
  notifies :restart, 'service[rsyslog]', :immediately
end

service 'rsyslog' do
  action [:enable, :start]
end
