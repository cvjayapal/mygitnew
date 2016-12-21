default[:sev1_security][:random] = "regsubst (#{node['network']['interfaces']['eth0']['addresses'].keys[1]},'^.*\.(\d+)\.(\d+)\.(\d+)$','\3\2\1')"
