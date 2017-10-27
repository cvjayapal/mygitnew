#
# Cookbook Name:: jnj_win_vpcx_task_uploadmonitormetrics
# Recipe:: default
#
# Copyright 2016, Relevance Lab
#
# All rights reserved - Do Not Redistribute
#
# Note: The uploadmonitormetrics task is using AWS PowerShell for it's scripting. This will not work in Azure.
# TODO: Azure solution needs to be scripted.

## For platfome = AWS
file node['windowspowershell']['v1.0'] do
  action :delete
end

node['jnj_win_vpcx_task_uploadmonitormetrics']['directory'].each do |path|
  directory path do
    owner  'Administrators'
    group  'Administrators'
    action :create
  end
end

if node['scm_hosting']['platform'] == 'AWS'
  @vpcx_path = if node['scm']['buildtype'] == 'buildworkflow'
                 'C:\\ProgramData\\JnJ\\Its_core\\vpcx'
               else
                 'C:\\Program Files\\vpcx'
               end
  vpcx = @vpcx_path

  # Task: UploadMonitorMetrics

  export_uploadmonitormetrics_tasks_folder = 'vpcx\\UploadMonitorMetrics'
  export_uploadmonitormetrics_ps1_path = "#{vpcx}\\upload-monitor-metrics.ps1"
  export_uploadmonitormetrics_xml_path = "#{vpcx}\\UploadMonitorMetrics.xml"

  # 1. copy upload-monitor-metrics.ps1 and related scripts to $vpcx_path

  cookbook_file export_uploadmonitormetrics_ps1_path.to_s do
    source 'upload-monitor-metrics.ps1'
    action :create
  end

  cookbook_file "#{vpcx}\\mon-put-metrics-mem.ps1" do
    source 'mon-put-metrics-mem.ps1'
    action :create
  end

  cookbook_file "#{vpcx}\\mon-put-metrics-partitions.ps1" do
    source 'mon-put-metrics-partitions.ps1'
    action :create
  end

  cookbook_file "#{vpcx}\\mon-shared.ps1" do
    source 'mon-shared.ps1'
    action :create
  end

  # 2. copy UploadMonitorMetrics.xml.erb template to $vpcx_path and create scheduled task

  if node['scm']['buildtype'] == 'buildworkflow'
    template export_uploadmonitormetrics_xml_path.to_s do
      source 'UploadMonitorMetrics.xml.erb'
      action :create
    end
    powershell_script 'Task_UploadMonitorMetrics' do
      creates "C:\\Windows\\System32\\Tasks\\'#{export_uploadmonitormetrics_tasks_folder}'"
      command "schtasks /create /f /tn \'#{export_uploadmonitormetrics_tasks_folder}\' /xml \'#{export_uploadmonitormetrics_xml_path}\'"
      returns 0
    end
  end
end
