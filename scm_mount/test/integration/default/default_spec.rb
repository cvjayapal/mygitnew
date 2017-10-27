describe directory('/rl') do
	it { should be_directory }
end
describe command('/sbin/mkfs -t ext2 /dev/sdb') do
	its('exit_status') { should eq 0 }
end 
describe mount('rl') do
	its('exit_status') { should eq 0 }
end
describe command('chown -R root:disk  /rl && \ touch /rl/.scm_mounted') do
	its('exit_status') { should eq 0 }
end 