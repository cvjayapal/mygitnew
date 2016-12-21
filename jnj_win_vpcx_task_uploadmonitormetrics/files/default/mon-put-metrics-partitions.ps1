<#

  Copyright 2012-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.

    Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

          http://aws.amazon.com/apache2.0/

    or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.


.SYNOPSIS
Collects partition information on an Amazon Windows EC2 instance and sends this data as custom metrics to Amazon CloudWatch. (Based on mon-put-metrics-disk.ps1.)

.DESCRIPTION
This script is used to send custom metrics to Amazon Cloudwatch. This script pushes disk utilization and snapshot age to cloudwatch. This script can be scheduled or run from a powershell prompt.
When launched from shceduler you need to specify logfile and all messages will be logged to logfile. You can use whatif and verbose mode with this script.

.PARAMETER disk_space_util
		Reports disk space utilization in percentages.
.PARAMETER disk_space_used
		Reports disk space used.
.PARAMETER disk_space_avail
		Reports available disk space.
.PARAMETER vss_age
		Reports time in seconds since the most recent volume shadow copy.
.PARAMETER disk_space_units
		Specifies units for disk space metrics.
.PARAMETER from_scheduler
		Specifies that this script is running from Task Scheduler.
.PARAMETER aws_access_id
		Specifies the AWS access key ID to use to identify the caller.
.PARAMETER aws_secret_key
		Specifies the AWS secret key to use to sign the request.
.PARAMETER aws_credential_file
		Specifies the location of the file with AWS credentials. Uses "AWS_CREDENTIAL_FILE" Env variable as default.
.PARAMETER logfile
		Logs all error messages to a log file. This is required when from_scheduler is set.
.PARAMETER version
		Shows the version of the script.
.PARAMETER bypassFIPSValidation
        Bypasses FIPS encryption checks for when AWS API request signatures are created.  Only required in environments where FIPS encryption validation is turned on by default

.NOTES


.EXAMPLE
    powershell.exe .\mon-put-metrics-partitions.ps1  -disk_space_util -disk_space_avail -disk_space_units kilobytes

.EXAMPLE
	powershell.exe .\mon-put-metrics-partitions.ps1  -disk_space_util -disk_space_used -disk_space_avail -disk_space_units gigabytes

.EXAMPLE
	powershell.exe .\mon-put-metrics-partitions.ps1  -disk_space_util -disk_space_units gigabytes  -from_scheduler -logfile C:\mylogfile.log

#>

[CmdletBinding(DefaultParametersetName="CredsFromFile", SupportsShouldProcess = $true) ]
param(
    [switch]$disk_space_util ,
    [switch]$disk_space_used ,
    [switch]$disk_space_avail,
    [switch]$vss_age ,
    [ValidateSet("bytes","kilobytes","megabytes","gigabytes" )]
    [string]$disk_space_units = "none",
    [switch]$from_scheduler,
    [string]$logfile,
    [Switch]$version,
    [switch]$bypassFIPSValidation = $true
)

$ErrorActionPreference = 'Stop'

# Include shared functions and script components
$scriptpath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Verbose "Script is in path $scriptpath"

$mon_shared = Join-Path $scriptpath "mon-shared.ps1"
. $mon_shared

### Check if atleast one metric is requested to report.###
if ( !$disk_space_avail -and !$disk_space_used -and !$disk_space_util -and !$vss_age ) {
	throw "Please specify a metric to report exiting script"
}

### Verifes the array of drive letters passed###
function Check-Disks {
	$drive_list_parsed = New-Object System.Collections.ArrayList
	foreach ( $drive in $disk_drive) {
		if ($drive.endswith(':')-and ($drive -match '^[a-z A-Z]:$')) {
			$ret=$drive_list_parsed.add($drive)
		}
		elseif ($drive -match '^[a-z A-Z]$') {

			$ret = $drive_list_parsed.add($drive.insert($drive.length,':'))
		}
		else {
			throw "Invalid Drive Letter: $drive"
		}
	}
	return $drive_list_parsed
}

### Function that gets disk stats using WMI###
function Get-DiskMetrics {
	begin{}
	process {
		$drive_list_parsed = New-Object System.Collections.ArrayList
		$disksinfo = Get-WMIObject Win32_volume -filter "DriveType=3"
		[System.Globalization.CultureInfo]$provider = [System.Globalization.CultureInfo]::InvariantCulture
		foreach ($diskinfo in $disksinfo){
			if (-Not ($diskinfo.DriveLetter) ) {
				continue
			}
			# the volume name needs to be escaped (replace \ with \\) before we can use it in the filter string
			$esc_volname = $diskinfo.DeviceID -replace "\\", "\\"
			$shadowcopies = Get-WMIObject "win32_shadowcopy" -filter "VolumeName='$esc_volname'"
			Write-Verbose "Found $($shadowcopies.count) shadow copies for $($diskinfo.DriveLetter) [$($diskinfo.DeviceID)]"
			if ($shadowcopies.count -eq 1) {
				# If there is just one shadow copy, it's returned directly rather than
				# in an array
				$recent_copy = $shadowcopies
				$install_date = [DateTime]::parseexact($recent_copy.InstallDate.Substring(0,$recent_copy.InstallDate.length-4), "yyyyMMddHHmmss.ffffff", $provider)
				Write-Verbose "The only shadow copy was created at $install_date"
			}
			elseif ($shadowcopies.count -gt 1) {
				$recent_copy = $shadowcopies[$shadowcopies.count-1]
				$install_date = [DateTime]::parseexact($recent_copy.InstallDate.Substring(0,$recent_copy.InstallDate.length-4), "yyyyMMddHHmmss.ffffff", $provider)
				Write-Verbose "Most recent shadow copy was created at $install_date"
			}
			else {
				# Use the OS installation date as the age
				$install_date = ([WMI]'').ConvertToDateTime((Get-WmiObject Win32_OperatingSystem).InstallDate)
				Write-Verbose "No previous shadow copy found. Report a maximum value of 1 week old."
			}
			$age_of_copy = [datetime]::Now.subtract($install_date)
			$diskobj = New-Object psobject
			add-member -InputObject $diskobj -MemberType NoteProperty -Name "deviceid" -Value $diskinfo.DriveLetter
			add-member -InputObject $diskobj -MemberType NoteProperty -Name "Freespace" -Value $diskinfo.Freespace
			add-member -InputObject $diskobj -MemberType NoteProperty -Name "size" -Value $diskinfo.Capacity
			Add-Member -InputObject $diskobj -MemberType NoteProperty -Name "UsedSpace" -Value ($diskinfo.Capacity - $diskinfo.Freespace)
			Add-Member -InputObject $diskobj -MemberType NoteProperty -Name "PartitionSnapshotAge" -Value ($age_of_copy.TotalSeconds)
			Write-Output $diskobj
		}
	}
	end{}
}

### Function that writes metrics to be piped to next fucntion to push to cloudwatch.###
function Create-DiskMetricList {
	param ([parameter(valuefrompipeline =$true)] $diskobj)
	begin {
		$units = Parse-Units -input_units $disk_space_units
        $dims = New-Object PSObject
        $inst_id = Get-InstanceMetadata("/instance-id")
        Add-Member -InputObject $dims -Name "Name" -MemberType NoteProperty -Value "InstanceId"
        Add-Member -InputObject $dims -Name "Value" -MemberType NoteProperty -Value $inst_id
	}
	process {
		$dimlist = New-Object System.Collections.ArrayList
		$dimlist.Add($dims) | Out-Null
		$dim_drive_letter = New-Object PSObject
        Add-Member -InputObject $dim_drive_letter -Name "Name" -MemberType NoteProperty -Value "DriveLetter"
        Add-Member -InputObject $dim_drive_letter -Name "Value" -MemberType NoteProperty -Value $diskobj.Deviceid
		$dimlist.Add($dim_drive_letter) | Out-Null

		if ($disk_space_util) {
			$percent_disk_util= 0
			if ( [long]$diskobj.size -gt 0 ) { $percent_disk_util = 100 * ([long]$diskobj.UsedSpace/[long]$diskobj.size)}
			write (Append-Metric "PartitionUtilization" "Percent"  ("{0:f2}" -f $percent_disk_util) $dimlist)
		}
		if ($disk_space_used) {
			write (Append-Metric "PartitionUsed" $units.unit_val ("{0:f2}" -f ([long]($diskobj.UsedSpace/$units.unit_div))) $dimlist)
		}
 		if ($disk_space_avail) {
			write (Append-Metric "PartitionAvailable" $units.unit_val ("{0:f2}" -f([long]($diskobj.Freespace/$units.unit_div))) $dimlist)
		}
 		if ($vss_age) {
			write (Append-Metric "PartitionSnapshotAge" "Seconds" ("{0:f2}" -f $diskobj.PartitionSnapshotAge) $dimlist)
		}
	}
	end{}
}


### Pipelined call of fucntions that pushs metrics to cloudwatch.
Get-DiskMetrics | Create-DiskMetricList | Put-InstanceData
