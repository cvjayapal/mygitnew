#
# Cookbook Name:: jnj_win_disable_services
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

 
windows_service 'SharedAccess' do
  action :configure_startup
  startup_type :manual
end
