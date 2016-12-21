<#

  Copyright 2012-2014 Amazon.com, Inc. or its affiliates. All Rights Reserved.

    Licensed under the Apache License, Version 2.0 (the "License"). You may not use this file except in compliance with the License. A copy of the License is located at

          http://aws.amazon.com/apache2.0/

    or in the "license" file accompanying this file. This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

.SYNOPSIS
Collects memory, and Pagefile utilization on an Amazon Windows EC2 instance and sends this data as custom metrics to Amazon CloudWatch.

.DESCRIPTION
This script is used to send custom metrics to Amazon Cloudwatch. This script pushes memory and page file utilization to cloudwatch. This script can be scheduled or run from a powershell prompt.
When launched from shceduler you need to specify logfile and all messages will be logged to logfile. You can use whatif and verbose mode with this script.

.PARAMETER mem_util
		Reports memory utilization in percentages.
.PARAMETER mem_used
		Reports memory used (excluding cache and buffers).
.PARAMETER mem_avail
		Reports available memory (including cache and buffers).
.PARAMETER memory_units
		Specifies units for memory metrics.
.PARAMETER from_scheduler
		Specifies that this script is running from Task Scheduler.
.PARAMETER aws_access_id
		Specifies the AWS access key ID to use to identify the caller.
.PARAMETER aws_secret_key
		Specifies the AWS secret key to use to sign the request.
.PARAMETER aws_credential_file
		Specifies the location of the file with AWS credentials. Uses "AWS_CREDENTIAL_FILE" Env variable as default.
.PARAMETER page_used
		Reports used page file space for all disks.
.PARAMETER page_avail
		Reports available space in page file for all disks.
.PARAMETER page_util
		Reports page file utilization in percentages for all disks.
.PARAMETER logfile
		Logs all error messages to a log file. This is required when from_scheduler is set.
.PARAMETER bypassFIPSValidation
        Bypasses FIPS encryption checks for when AWS API request signatures are created.  Only required in environments where FIPS encryption validation is turned on by default


.NOTES

.EXAMPLE
    powershell.exe .\mon-put-metrics-mem.ps1  -mem_util -mem_avail -memory_units kilobytes
.EXAMPLE
	powershell.exe .\mon-put-metrics-mem.ps1  -mem_util -mem_used -mem_avail -memory_units kilobytes  -page_avail -page_used -page_util
.EXAMPLE
	powershell.exe .\mon-put-metrics-mem.ps1  -mem_util -mem_used -memory_units gigabytes  -page_avail -page_util -from_scheduler -logfile C:\mylogfile.log

#>
[CmdletBinding(DefaultParametersetName="CredsFromFile", supportsshouldprocess = $true) ]
param(
    [switch]$mem_util,
    [switch]$mem_used ,
    [switch]$mem_avail,
    [switch]$page_used,
    [switch]$page_avail,
    [switch]$page_util,
    [ValidateSet("bytes","kilobytes","megabytes","gigabytes" )]
    [string]$memory_units = "none",
    [switch]$from_scheduler,
    [string]$logfile = $null,
    [Switch]$version,
    [switch]$bypassFIPSValidation = $true
)

$ErrorActionPreference = 'Stop'

# Include shared functions and script components
$scriptpath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Verbose "Script is in path $scriptpath"

$mon_shared = Join-Path $scriptpath "mon-shared.ps1"
. $mon_shared


### Function that gets memory stats using WMI###
function Get-Memory {
    begin {}
    process {
	    $mem = New-Object psobject
	    $units = Parse-Units -input_units $memory_units
 	    [long]$mem_avail_wmi = (get-WmiObject Win32_OperatingSystem | select -expandproperty FreePhysicalMemory) * 1kb
 	    [long]$total_phy_mem_wmi = get-WmiObject Win32_ComputerSystem |  select -expandproperty TotalPhysicalMemory
 	    [long]$mem_used_wmi = $total_phy_mem_wmi - $mem_avail_wmi
 	    Add-Member -InputObject $mem -Name "mem_avail_wmi" -MemberType NoteProperty -Value $mem_avail_wmi
 	    Add-Member -InputObject $mem -Name "total_phy_mem_wmi" -MemberType NoteProperty -Value $total_phy_mem_wmi
 	    Add-Member -InputObject $mem -Name "mem_used_wmi" -MemberType NoteProperty -Value $mem_used_wmi
 	    Add-Member -InputObject $mem -Name "mem_units" -MemberType NoteProperty -Value $units.unit_val
 	    Add-Member -InputObject $mem -Name "mem_unit_div" -MemberType NoteProperty -Value $units.unit_div
 	    write $mem
    }
    end{}
}

### Function that writes metrics to be piped to next fucntion to push to cloudwatch.###
function Create-MetricList {
    param ([parameter(Valuefrompipeline=$true)] $mem_info)
    begin {
        $dims = New-Object PSObject
        $inst_id = Get-InstanceMetadata("/instance-id")
        Add-Member -InputObject $dims -Name "Name" -MemberType NoteProperty -Value "InstanceId"
        Add-Member -InputObject $dims -Name "Value" -MemberType NoteProperty -Value $inst_id
        $dimlist = New-Object System.Collections.ArrayList
        $dimlist.Add($dims) | Out-Null
        $pagefilessize = @{}
        $pagefileusage = @{}
        gwmi Win32_PageFileSetting | ForEach-Object{$pagefilessize[$_.name]=$_.MaximumSize *1mb}
        gwmi Win32_PageFileUsage | ForEach-Object{$pagefileusage[$_.name]=$_.currentusage *1mb}
        [string[]]$pagefiles = $pagefilessize.keys
    }
    process {
        if ($mem_util) {
	        $percent_mem_util= 0
	        if ( [long]$mem_info.total_phy_mem_wmi -gt 0 ) { $percent_mem_util = 100 * ([long]$mem_info.mem_used_wmi/[long]$mem_info.total_phy_mem_wmi) }
	        write (Append-Metric "MemoryUtilization" "Percent"  ("{0:f2}" -f $percent_mem_util) $dimlist)
	    }
	    if ($mem_used) {
	        write (Append-Metric "MemoryUsed" $mem_info.mem_units ("{0:f2}" -f ([long]($mem_info.mem_used_wmi/$mem_info.mem_unit_div))) $dimlist)
	    }
 	    if ($mem_avail) {
		    write (Append-Metric "MemoryAvailable" $mem_info.mem_units ("{0:f2}" -f ([long]($mem_info.mem_avail_wmi/$mem_info.mem_unit_div))) $dimlist)
	    }
	    if ($page_avail) {
	        for ($i=0; $i -le ($pagefiles.count - 1);$i++) {
                write (Append-Metric ("pagefileAvailable("+$pagefiles[$i]+")") $mem_info.mem_units ("{0:f2}" -f ((($pagefilessize[$pagefiles[$i]]- ($pagefileusage[$pagefiles[$i]]))/$mem_info.mem_unit_div))) $dimlist)
		    }
        }
	    if ($page_used) {
		    for ($i = 0; $i -le ($pagefiles.count -1); $i++) {
			    write (Append-Metric ("pagefileUsed("+$pagefiles[$i]+")") $mem_info.mem_units ("{0:f2}" -f (($pagefileusage[$pagefiles[$i]])/$mem_info.mem_unit_div)) $dimlist)
		    }
	    }
	    if ($page_util)
	    {
		    for ($i=0; $i -le ($pagefiles.count -1);$i++) {
			    if($pagefilessize[$pagefiles[$i]] -gt 0 ) {
				    write (Append-Metric ("pagefileUtilization("+$pagefiles[$i]+")") "Percent" ("{0:f2}" -f((($pagefileusage[$pagefiles[$i]])*100)/$pagefilessize[$pagefiles[$i]])) $dimlist)
			    }
		    }
	    }
    }
    end{}
}

### Pipelined call of fucntions that pushs metrics to cloudwatch.
Get-Memory | Create-MetricList | Put-InstanceData
