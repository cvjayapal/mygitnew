#
# Cookbook Name:: jnj_win_version
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

# directory 'C:\\ProgramData\\JnJ\\Its_core' do
#   owner 'Administrators'
#     group 'Administrators'
#   acion :create
#
# %w( C:\\ProgramData C:\\ProgramData\\JnJ C:\\ProgramData\\JnJ\\Its_core ).each do |path|
# %w( C:\\ProgramData C:\\ProgramData\\JnJ C:\\ProgramData\\JnJ\\Its_core ).each do |path|
directory "C:\\ProgramData\\JnJ\\Its_core" do
    owner 'Administrators'
    group 'Administrators'
    mode '0755'
    action :create
    recursive true
  end
# end

cookbook_file node['jnj_win_version']['file'] do
  source 'its_core_version.txt'
  owner 'Administrators'
  group 'Administrators'
  mode 0664
  action :create
end

cookbook_file node['jnj_win_version']['path'] do
  source 'version.txt'
  owner 'Administrators'
  group 'Administrators'
  mode 0664
  action :create
end
