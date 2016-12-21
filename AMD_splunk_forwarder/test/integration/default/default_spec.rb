describe file('splunkforwarder-6.5.0-59c8927def0f-linux-2.6-x86_64.rpm') do
  it { should be_file }
end 
describe file('/tmp/splunk.sh') do
  it { should be_file }
end 
describe file('./splunk.sh') do
  it { should be_file }
end 

