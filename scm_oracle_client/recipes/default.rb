#
# Cookbook Name:: scm_oracle_client
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
install_type = 'basic'
version = '11.2'
manage_tnsnames = false
tnsnames = undef
clean_backup = false
# Params for basic install
# SCM Managed application S3 bucket where this scm_oracle_client module will install from
s3bucket = "https://s3.amazonaws.com/jnj-#{vpcxprefix}vpcx-scm/packages/oracle"

# Set version of the Oracle client to be installed in oracle_version
# Set the appropriate $oracle_version and $oracle_package for the rpm 
# Verify oracle_home is appropriate for your Oracle version.
oracle_version    = "11.2"
oracle_package    = "0.4.0-1"
oracle_package_full = "0.4.0"
oracle_client_basic = "oracle-instantclient#{oracle_version}-basic-#{oracle_version}.#{oracle_package}.x86_64"
oracle_client_devel = "oracle-instantclient#{oracle_version}-devel-#{oracle_version}.#{oracle_package}.x86_64"
oracle_client_sqlplus  = "oracle-instantclient#{oracle_version}-sqlplus-#{oracle_version}.#{oracle_package}.x86_64"

# Params for full install
oracle_archive_file = 'p13390677_112040_Linux-x86-64_4of7.zip'
case node['scm_oracle_client']['install_type']
when 'basic'
    oracle_home = "/usr/lib/oracle/#{oracle_version}/client64"
when 'full'
    oracle_home = "/u01/app/oracle/product/#{oracle_version}.#{oracle_package_full}/client_2"
default
    fail ("Unknown install type. Please specify 'basic' or 'full'")
end
oracle_base        = '/u01/app/oracle'
unix_group_name    = 'oinstall'
inventory_location = '/u01/app/oraInventory'
dbd_package        = 'DBD-Oracle-1.74.tar.gz'
dbd_directory      = '/usr/local/dbd'

include_recipe 'scm_oracle_client::install'
