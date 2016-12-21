#
# Cookbook Name:: mode
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#
# cookbook_file '/etc/motd' do
# 	source 'motd'
# 	owner 'root'
# 	group 'root'
# 	mode  '0644'
# 	action :create
# end

# file '/etc/motd' do
#   content 'This is a private computer facility. Access to it for any reason must
#       be specifically authorized.  Unless you are  specifically authorized,
#       your continued access and  further inquiry may expose you to criminal
#       and/or civil proceedings'
#   mode '0644'
#   owner 'root'
#   group 'root'
# end

template '/etc/motd' do
  source 'motd.erb'
  action :create
  mode '0644'
end
