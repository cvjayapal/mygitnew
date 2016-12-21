#
# Cookbook Name:: jnj_hostname
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'spec_helper'
describe 'jnj_hostname::default' do
  context 'When all attributes are default, on an RHEL6 platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '6.0')
      runner.converge(described_recipe)
    end
    it'check the content of the file' do
      stub_command('/etc/sysconfig/network').and_return(true)
    end
  end
  context 'When all attributes are default, on an RHEL7 platform' do
    let(:chef_run) do
      runner = ChefSpec::ServerRunner.new(platform: 'centos', version: '7.0')
      runner.converge(described_recipe)
    end
    it'check the content of the file' do
      stub_command('/etc/hosts').and_return(true)
    end

    it 'execute resource sucessfully' do
      # expect(chef_run).to run_bash('command').with_cwd('grep Fauxhai /etc/hosts')
      stub_command('grep Fauxhai /etc/hosts').and_return(true)
    end
  end
end
