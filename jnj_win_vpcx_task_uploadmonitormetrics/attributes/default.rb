default['jnj_win_vpcx_task_uploadmonitormetrics']['directory'] = %w( C:\\ProgramData C:\\ProgramData\\JnJ C:\\ProgramData\\JnJ\\Its_core C:\\ProgramData\\JnJ\\Its_core\\vpcx)
default['scm_hosting']['platform'] = 'AWS'
default['scm']['buildtype'] = 'buildworkflow'
default['windowspowershell']['v1.0'] = 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe.config'
default['win_jnj']['export_uploadmonitormetrics_ps1_path'] = "#{node['win_jnj']['vpcx_path']}\\upload-monitor-metrics.ps1"
default['win_jnj']['export_uploadmonitormetrics_xml_path'] = "#{node['win_jnj']['vpcx_path']}\\UploadMonitorMetri"
