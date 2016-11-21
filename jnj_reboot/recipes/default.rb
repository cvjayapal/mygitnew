#
# Cookbook Name:: jnj_reboot
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
#execute 'needs_reboot' do
  #action :request_reboot
  #reason 'This system needs to be REBOOTED'
#command '/bin/tput smso > /dev/"[pt]t[ys][0-9]"; /bin/wall hello-world > /dev/[pt]t[ys][0-9]; /bin/tput rmso > /dev/[pt]t[ys][0-9]'
#  action :run  
  #delay_mins 1
  #command 'sudo init 6' 
#end
execute 'needs_reboot' do
	command '/bin/tput smso > /dev/"[pt]t[ys][0-9]"; /bin/echo "This system needs to be REBOOTED" > /dev/[pt]t[ys][0-9]; /bin/tput rmso > /dev/[pt]t[ys][0-9]'
end
reboot 'requires_reboot' do
	action :request_reboot
	reason 'This system needs to be REBOOTED'
	delay_mins 1
end
 