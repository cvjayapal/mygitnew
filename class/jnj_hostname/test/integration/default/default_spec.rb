control 'jnj_hostname' do
  # if os [:version] == '7'
  describe file('/etc/hosts') do
    it { should be_owned_by 'root' }
    it { should be_grouped_into 'root' }
    # it { should be_mode '0644' }
    # its('content') {should match(%r{variable}) }
  end
end
# end
