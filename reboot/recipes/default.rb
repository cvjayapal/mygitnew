#
# Cookbook Name:: reboot
# Recipe:: default
#
# Copyright 2016, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
# execute "needs_reboot" do
#  command "/usr/bin/tput smso;/bin/echo 'This system needs to be REBOOTED';/usr/bin/tput rmso;sudo init 6"
# end

# execute 'needs_reboot' do
# action :request_reboot
# reason 'This system needs to be REBOOTED'
# command '/bin/tput smso > /dev/"[pt]t[ys][0-9]"; /bin/wall hello-world > /dev/[pt]t[ys][0-9]; /bin/tput rmso > /dev/[pt]t[ys][0-9]'
#  action :run
# delay_mins 1
# command 'sudo init 6'
# end

# execute 'request_reboot' do
#  action :request_reboot
#  reason 'Cannot continue Chef run without a reboot.'
#  delay_mins 2
# end
# execute "sudo init 6" do
#  command '/usr/bin/tput smso&&/bin/echo "This system needs to be REBOOTED"&&/usr/bin/tput rmso'
# end
# bash 'needs_reboot' do
#  code <<-EOH
#    /bin/tput smso
#    /bin/echo 'This system needs to be REBOOTED'
#    /bin/tput rmso
#    EOH
# end
# bash 'needs_reboot' do
#  code <<-EOH
# /bin/echo 'This system needs to be REBOOTED'
#  EOH
# end
# execute 'needs_reboot' do
# action :request_reboot
# reason 'This system needs to be REBOOTED'
#  command '/bin/tput smso > /dev/"[pt]t[ys][0-9]"; /bin/wall "This system needs to be REBOOTED" > /dev/[pt]t[ys][0-9]; /bin/tput rmso > /dev/[pt]t[ys][0-9]'
# end
execute 'needs_reboot' do
  command '/bin/tput smso > /dev/"[pt]t[ys][0-9]"; /bin/echo "This system needs to be REBOOTED" > /dev/[pt]t[ys][0-9]; /bin/tput rmso > /dev/[pt]t[ys][0-9]'
end
reboot 'requires_reboot' do
  action :request_reboot
  reason 'This system needs to be REBOOTED'
  delay_mins 1
end
