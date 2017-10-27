#
# Cookbook Name::scm_mount
# Spec:: default
#
# Copyright (c) 2016 The Authors, All Rights Reserved.

# require 'chefspec'
# describe 'scm_mount::default' do
# let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '7.2').converge(described_recipe) }
# # let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '7.2').converge(described_recipe) }
# it 'includes the `other` recipe' do
#   	expect(chef_run).to include_recipe('scm_mount::init')
#   end
#   if "df -h | grep /dev/sdb > /dev/null" 
# it "execute command" do
#   expect(chef_run).to run_execute('/sbin/mkfs -t ext2 /dev/sdb')
# end
# end
# it "mount a directory" do
#      expect(chef_run).to mount_mount('rl')
#    end
#    if 'test -e | grep /rl > /dev/null'
  
# it "execute command" do
#   expect(chef_run).to run_execute('chown -R root:disk  /rl && touch /rl/.scm_mounted').with_cwd('/usr/bin')
# end
# end 


# end
require 'chefspec'
describe 'scm_mount::default' do
let(:chef_run) { ChefSpec::SoloRunner.new(platform: 'centos', version: '7.2.1511').converge(described_recipe) }


it 'includes the other recipe' do
 stub_command("/sbin/blkid /dev/sdb").and_return(false)
 stub_command("test -e /rl/.scm_mounted").and_return(true)
 expect(chef_run).to include_recipe('scm_mount::init')
end
it 'creates a directory' do
  stub_command("/sbin/blkid /dev/sdb").and_return(false)
  stub_command("test -e /rl/.scm_mounted").and_return(false)
  expect(chef_run).to create_directory('/rl')
  end
  # if "df -h | grep /dev/sdb > /dev/null" 
# it "execute command" do
#   stub_command("/sbin/blkid /dev/sdb").and_return(false)
#    stub_command("test -e rl/.scm_mounted").and_return(false)
#   expect(chef_run).to run_execute('/sbin/mkfs -t ext2 /dev/sdb')
# end
# end
 it 'mount a directory' do
  stub_command("/sbin/blkid /dev/sdb").and_return(false)
  stub_command("test -e /rl/.scm_mounted").and_return(false)
  expect(chef_run).to mount_mount('/rl')
  #    # stub_command("/sbin/blkid /dev/xvdc").and_return(false)
 end
  
  # it 'execute a command' do
  #   stub_command("/sbin/blkid /dev/sdb").and_return(false)
  #   stub_command("test -e /rl/.scm_mounted").and_return(false)
  #   expect(chef_run).to run_execute('chown -R root:disk //rl && \ touch /rl/.scm_mounted')
  # #   expect(chef_run).to run_execute('chown -R root:disk /rl && \ touch /rl/.scm_mounted')
  # #   # expect(chef_run).to run_execute("chown_#{node['scm_mount']['owner']}_#{node['scm_mount']['group']}")
  # #   # [chown -R root : disk /rl && \ touch /rl/.scm_mounted]
  # #   # "chown -R #{node['scm_mount']['owner']}:#{node['scm_mount']['group']}  /#{node['scm_mount']['directory']} && \ touch /#{node['scm_mount']['directory']}/.scm_mounted"
  # #   # expected "execute[chown -R root:disk  /rl && touch /rl/.scm_mounted]"
  # #   # stub_command("/sbin/blkid /dev/xvdc").and_return(false)
  # #   # stub_command('test -e rl/.scm_mounted').and_return(false)\ touch /#{node['scm_mount']['directory']
  # #   # ::File.stub(:exists?).with('test -e rl/.scm_mounted').and_return(false)
  #  end
# it "mount a directory" do
#      expect(chef_run).to mount_mount('rl')
#    end
#    if 'test -e | grep /rl > /dev/null'.with_cwd('/usr/bin')
  
# it "execute command" do
#   expect(chef_run).to run_execute('chown -R root:disk  /rl && touch /rl/.scm_mounted').with_cwd('/usr/bin')
# end
# end 
# chown -R root : disk /rl && \ touch /rl/.scm_mounted


end