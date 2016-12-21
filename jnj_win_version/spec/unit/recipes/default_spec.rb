#
# Cookbook Name:: jnj_win_version
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

require 'chefspec'
describe 'jnj_win_version::default' do
let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'windows', version: '2008r2').converge(described_recipe) }

 it'create directory successfully' do
 	expect(chef_run).to create_directory('C:\\ProgramData\\JnJ\\Its_core').with(
 		     owner: 'Administrators',
         group: 'Administrators',
         mode: '0755'
        )
 end

 it'create cookbook file successfully' do
 expect(chef_run).to create_cookbook_file('C:\\Windows\\its_core_version.txt').with(
 	       owner: 'Administrators',
         group: 'Administrators',
         mode: '0644'
         )
end

it'create cookbook file successfully' do
 expect(chef_run).to create_cookbook_file('C:\\ProgramData\\JnJ\\Its_core\\version.txt').with(
 	       owner: 'Administrators',
         group: 'Administrators',
         mode: '0644'
         )
end
end
