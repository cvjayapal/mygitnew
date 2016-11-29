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

%w[ C:\\ProgramData C:\\ProgramData\\PuppetLabs C:\\ProgramData\\PuppetLabs\\facter C:\\ProgramData\\PuppetLabs\\facter\\facts.d ].each do |path|
  directory path do
    owner  'Administrators'
    group  'Administrators'
    action :create
  end
end

cookbook_file 'C:\\ProgramData\\PuppetLabs\\facter\\facts.d\\scm_facts.ps1' do
        source 'scm_facts.ps1'
        owner  'Administrators'
        group  'Administrators'
        mode  0775
        action :create       
end

file 'C:\\ProgramData\\PuppetLabs\\facter\\facts.d\\aws_facts.ps1' do
        
        action :delete        
end

