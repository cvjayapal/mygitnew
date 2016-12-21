#
# Cookbook Name:: scm_windows_shortcut
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
shortcut = node['scm_windows_shortcut']['title']
powershell_script "create_shortcut_shortcut" do
	command "template('scm_windows_shortcut/shortcut.ps1.erb')"
    #onlyif "template('scm_windows_shortcut/shortcut.ps1')"
    provider Chef::Provider::PowershellScript
end

    

    