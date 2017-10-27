#
# Cookbook Name:: jnj_win_administrator
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
if scm_buildtype == "buildworkflow" 
  node['user']['win_administrator']

  cmd_rename   = "Invoke-CimMethod -Query 'SELECT * FROM Win32_UserAccount WHERE LocalAccount=\"True\" AND SID like \"S-1-5-%-500\"' -MethodName \"Rename\" -Arguments @{\"Name\"=\"#{new_username}\"}"
   
  cmd_verify   = "if (Get-WmiObject Win32_UserAccount -Filter 'LocalAccount=\"True\" And Name=\"#{new_username}\" AND SID like \"S-1-5-%-500\"') { exit 0 } else { exit 1 }"


  execute 'win_administrator' do
  command cmd_rename
  not_if cmd_verify
  provider Chef::Provider::Execute
end
