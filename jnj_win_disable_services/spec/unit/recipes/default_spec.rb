#
# Cookbook Name:: jnj_hostname
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require'chefspec'
describe'jnj_win_disable_services::default'do
  let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'windows', version: '2008r2').converge(described_recipe) }
it 'configures startup for a windows_service when specifying the identity attribute' do
  expect(chef_run).to configure_startup_windows_service('SharedAccess')
  end
end