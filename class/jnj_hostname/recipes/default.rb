#
# Cookbook Name:: jnj_hostname
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

fact_hostname = node['hostname']
vpcx_hostname = node['jnj_hostname']['hostname']

if node['hostname'] != vpcx_hostname && vpcx_hostname != ''
  if node['platform_version'].to_i == 6
    execute "run_command" do
      command "hostname #{vpcx_hostname} && sed -i s/HOSTNAME=.*/HOSTNAME=#{vpcx_hostname}/g /etc/sysconfig/network && echo '#{node['jnj_hostname']['host']['name']} > /etc/hostname'"
    end
  else node['platform_version'].to_i == 7
    execute 'run_command' do
      command "hostnamectl set-hostname #{vpcx_hostname}"
    end
    execute "Update_Hostname_in_network_config" do
      command 'sed -i s/HOSTNAME=.*/HOSTNAME=#{fact_hostname}/g /etc/sysconfig/network'
    end
  end
  execute "Replace_Hostname_in_Hosts_Mapping" do
    command 'sed -i s/#{fact_hostname}/#{vpcx_hostname}/g /etc/hosts'
    only_if 'grep #{fact_hostname} /etc/hosts'
  end
end

# vpcx_hostname = node['jnj_hostname']['hostname']
# fact_hostname = "#{vpcx_hostname}"
# # vpcx_hostname = String.new(node['jnj_hostname']['hostname'])
# # fact_hostname = vpcx_hostname.downcase
# if node['hostname'] != fact_hostname && fact_hostname !=''
#   if node['platform_version'].to_i == 6
#     execute "run_command" do
#       command 'hostname #{fact_hostname}'
#     end
#     execute "Update_Hostname_in_network_config" do
#       command 'sed -i s/HOSTNAME=.*/HOSTNAME=#{fact_hostname}/g /etc/sysconfig/network'
#     end
#   else node['platform_version'].to_i == 7
#     execute 'set_hostname' do
#       command "hostnamectl set-hostname #{fact_hostname}"
#     end
#   end
#   execute "Replace_Hostname_in_Hosts_Mapping" do
#       command "sed -i s/#{node['hostname']}/#{fact_hostname}/g /etc/hosts"
#       only_if "grep node['hostname'] /etc/hosts"
#   end
# end
