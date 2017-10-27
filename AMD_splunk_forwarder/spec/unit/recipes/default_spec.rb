#
# Cookbook Name:: AMD_splunk_forwarder
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

 require 'spec_helper'
 describe 'AMD_splunk_forwarder::default' do
let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '7.2').converge(described_recipe) }
it 'execute coomand' do
    expect(chef_run).to run_execute('splunkforwarder-6.5.0-59c8927def0f-linux-2.6-x86_64.rpm')
end
it 'creates a template' do
    expect(chef_run).to create_template('/tmp/splunk.sh').with_user(
        mode: '755'
        )
end
it 'enable splunk on boot' do
    expect(chef_run).to run_execute('./splunk.sh')
end
end




