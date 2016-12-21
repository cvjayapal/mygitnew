# #
# # Cookbook Name:: scm_mount
# # Recipe:: default
# #
# # Copyright 2016, YOUR_COMPANY_NAME
# #
# # All rights reserved - Do Not Redistribute
# #

include_recipe 'scm_mount::init'
directory "#{node['scm_mount']['directory']}" do
	action :create
end
execute "mkfs_node['scm_mount']['title']" do 
	command "/sbin/mkfs -F -t #{node['scm_mount']['fstype']} #{node['scm_mount']['device']}"
	not_if "/sbin/blkid #{node['scm_mount']['device']}"
end
mount "#{node['scm_mount']['directory']}" do
	device "#{node['scm_mount']['device']}"
	fstype "#{node['scm_mount']['fstype']}"
	action :mount
	# enabled  :FalseClass
	options 'defaults'
end
execute "chown_#{node['scm_mount']['owner']}_#{node['scm_mount']['group']}" do
	cwd "/usr/bin" 
	command "chown -R #{node['scm_mount']['owner']}:#{node['scm_mount']['group']}  /#{node['scm_mount']['directory']} && \ touch /#{node['scm_mount']['directory']}/.scm_mounted"
	not_if "test -e #{node['scm_mount']['directory']}/.scm_mounted"
end
