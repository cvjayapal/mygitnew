#
# Cookbook Name:: jnj_win_hostname
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
fact_hostname = node['hostname']
vpcx_hostname = node['jnj_win_hostname']['hostname']

if hostname != fact_hostname 
	notify "Invalid hostname  hostname. Reset hostname to #{fact_hostname}"

   execute 'Rename_Computer' do
      command   "(Get-WmiObject Win32_ComputerSystem).Rename('#{fact_hostname}')"
      provider  'Chef::Provider::powershell'
      notify    'Reboot['Complete_Rename']'
  end 
  reboot 'Complete_Rename' do
    action :nothing   
end


