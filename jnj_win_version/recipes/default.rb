#
# Cookbook Name:: jnj_win_version
# Recipe:: default
#
# Copyright 2016, Relavance Lab
#
# All rights reserved - Do Not Redistribute

%w(C:\\ProgramData C:\\ProgramData\\JnJ C:\\ProgramData\\JnJ\\Its_core ).each do |path|
  directory path do
    owner 'Administrators'
    group 'Administrators'
    mode '0755'
    action :create
  end
end

cookbook_file node['jnj_win_version']['file'] do
  source 'version.txt'
  owner 'Administrators'
  group 'Administrators'
  mode  '0644'
  action :create
end

cookbook_file node['jnj_win_version']['path'] do
  source 'version.txt'
  owner 'Administrators'
  group 'Administrators'
  mode  '0644'
  action :create
end
