#
# Cookbook Name:: AMD_splunk_forwarder
# Recipe:: default
#
# Copyright 2016, Relevance Lab Pvt LTD, Inc.
#
# All rights reserved - Do Not Redistribute
#

package 'expect'

execute "download splunk forwarder" do
	cwd '/tmp'
	command <<-EOF
	wget -O "#{node[:AMD_splunk_forwarder][:splunk_rpm_pkg]}" "#{node[:AMD_splunk_forwarder][:splunk_url]}"
	EOF
end

# execute "run rpm install" do
# 	cwd '/tmp'
# 	command <<-EOF
# 	rpm -i "#{node[:AMD_splunk_forwarder][:splunk_rpm_pkg]}"
# 	EOF
# end

# execute "enable splunk on boot" do 
# 	command "#{node[:AMD_splunk_forwarder][:splunk_path]} enable boot-start"
# end

template '/tmp/splunk.sh' do
 	source 'splunk.sh.erb'
 	mode '755'
end

execute "enable splunk on boot" do
	cwd '/tmp'
	command "./splunk.sh"
end
