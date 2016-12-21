default[:AMD_splunk_forwarder][:splunk_forwarder_pkg] = 'splunkforwarder'
default[:AMD_splunk_forwarder][:version] = '6.5.0'
default[:AMD_splunk_forwarder][:splunk_rpm_pkg] = "#{node[:AMD_splunk_forwarder][:splunk_forwarder_pkg]}-#{node[:AMD_splunk_forwarder][:version]}-59c8927def0f-linux-2.6-x86_64.rpm"
default[:AMD_splunk_forwarder][:splunk_url] = 'https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=6.5.0&product=universalforwarder&filename=splunkforwarder-6.5.0-59c8927def0f-linux-2.6-x86_64.rpm&wget=true'
default[:AMD_splunk_forwarder][:splunk_path] = '/opt/splunkforwarder/bin/splunk'