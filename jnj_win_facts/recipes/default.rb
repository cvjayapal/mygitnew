#
# Cookbook Name:: jnj_win_facts
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

# directory 'C:\\ProgramData\\PuppetLabs' do
#         action :create
#         owner  'Administrators'
#         group  'Administrators'

# end

# directory 'C:\\ProgramData\\PuppetLabs\\facter' do
#         action :create
#         owner  'Administrators'
#         group  'Administrators'

# end

# directory 'C:\\ProgramData\\PuppetLabs\\facter\\facts.d' do
#         action :create
#         owner  'Administrators'
#         group  'Administrators'

# end
node['jnj_win_facts']['directory'].each do |path|
  directory path do
    owner  'Administrators'
    group  'Administrators'
    action :create
  end
end

cookbook_file node['jnj_win_facts']['file'] do
  source 'scm_facts.ps1'
  owner  'Administrators'
  group  'Administrators'
  mode 0775
  action :create
end

# file 'C:\\ProgramData\\PuppetLabs\\facter\\facts.d\\aws_facts.ps1' do
file node['jnj_win_facts']['file1'] do
  action :delete
end
