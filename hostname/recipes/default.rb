# #
# # Cookbook Name:: hostname
# # Recipe:: default
# #
# # Copyright 2016, YOUR_COMPANY_NAME
# #
# # All rights reserved - Do Not Redistribute
# #
fact_hostname = node['hostname']
vpcx_hostname = "krishna"
case node['platform_family']
when "centos"
 if node['platform_version'] == 6
   execute "hostname #{vpcx_name}"
   command "sed -i s/HOSTNAME=.*/HOSTNAME=#{vpcx_hostname}/g /etc/sysconfig/network"
 else node['platform_version'] == 7
   execute "hostnamectl set-hostname #{vpcx_hostname}"
   execute "sed -i s/#{fact_hostname}/#{vpcx_hostname}/g /etc/hosts"
end
end

# fact_hostname = node['hostname']
# vpcx_hostname = node['host']['name']
# if node['hostname'] != fact_hostname && fact_hostname !=''
#   if node['platform_version'] == 6
#   execute 'run_command' do
#     command "hostname #{vpcx_hostname} && sudo /bin/sed -i s/HOSTNAME=.*/HOSTNAME=#{vpcx_hostname}/g /etc/sysconfig/network"
#     end
#   else node['platform_version'] == 7
#     execute 'run_command' do
#     command "hostnamectl set-hostname #{vpcx_hostname} && sudo /bin/sed -i s/#{fact_hostname}/${vpcx_hostname}/g /etc/hostname"
#     end
#     end
#     execute 'Replace_Hostname_in_Hosts_Mapping' do
#       cwd "sudo /bin/sed -i s/#{fact_hostname}/#{vpcx_hostname}/g /etc/hosts"
#       only_if "grep #{fact_hostname} /etc/hosts"
#     end
# end
