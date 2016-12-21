#
# Cookbook Name:: sev1_security
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

cron 'Sev1' do
  command "/usr/bin/yum -y -q --disablerepo=* --enablerepo=jnj-s3-sev1-security-RHEL#{node['platform_version'].to_i} update >> /var/log/sev1-security.log 2>&1"
  environment 'env' => 'MAILTO=root'
  user 'root'
  minute '#{node[:sev1_security][:random]} % 59'
  hour '3,9,15,21'
end
