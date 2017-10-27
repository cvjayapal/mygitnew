#
# Cookbook Name::scm_mount
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.
require 'chefspec'
describe 'scm_mount::default' do
let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '7.2.1511').converge(described_recipe) }
class Scm_mount
end
end