# Shared scripts and functions for JnJ CloudWatch Metric scripts
$ErrorActionPreference = 'Stop'

### Initliaze common variables ###
$time = Get-Date
$invoc = (Get-Variable myinvocation -Scope 0).value
$currdirectory = Split-Path $invoc.mycommand.path
$scriptname = $invoc.mycommand.Name
$AWSToolsPath = "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell"
$ver = '1.0.0'

### Logs all messages to file or prints to console based on from_scheduler setting. ###
function Report-Message ([string]$message) {
	if($from_scheduler) {	
        if ($logfile.Length -eq 0 )	{
			$logfile = $currdirectory +"\" +$scriptname.replace('.ps1','.log')
		}
		$message | Out-File -Append -FilePath $logfile
	}
	else {
		Write-Host $message
	}
}

### Function that validates units passed. Default value of  Megabytes is used###
function Parse-Units {
	param ([string]$input_units,
           [string]$unit_value,
		   [long]$unit_div)
	$units = New-Object PSObject
	switch ($input_units.ToLower()) {
		"bytes" 	{ $unit_value = "Bytes"; $unit_div = 1 }
		"kilobytes" { $unit_value = "Kilobytes"; $unit_div = 1kb }
		"megabytes" { $unit_value = "Megabytes"; $unit_div = 1mb }
		"gigabytes" { $unit_value = "Gigabytes"; $unit_div = 1gb }
		default 	{ $unit_value = "Megabytes"; $unit_div = 1mb }
    }
	Add-Member -InputObject $units -Name "unit_val" -MemberType NoteProperty -Value $unit_value
 	Add-Member -InputObject $units -Name "unit_div" -MemberType NoteProperty -Value $unit_div
	return $units
}

### Function that creates metric data which will be added to metric list that will be finally pushed to cloudwatch. ###
function Append-Metric {
    if (-not($args -eq  $null)) {
        $dimslist = $args[3]
        $dimslist_string = "Dimensions=["
        foreach($dim in $dimslist){
            $dimslist_string += "{Name=$($dim.Name),Value=$($dim.Value)},"
        }
        $dimslist_string = $dimslist_string.Substring(0, ($dimslist_string.Length -1))
        $dimslist_string += "]"
        $metricdata = "MetricName=$($args[0]),$($dimslist_string),Timestamp='$($time.ToUniversalTime())',Value=$($args[2]),Unit=$($args[1])"
	    return $metricdata
    }
}

### Functions that interact with metadata to get data required for dimenstion calculation and endpoint for cloudwatch api. ###
function Get-InstanceMetaData {
    $wc = New-Object Net.WebClient
	$extendurl = $args
	$baseurl = "http://169.254.169.254/latest/meta-data"
	$fullurl = $baseurl + $extendurl
	return ($wc.DownloadString($fullurl))
}

### Gets the region where *this* instance is located via the Instance MetaData service
function Get-InstanceRegion {
	$az = Get-InstanceMetaData ("/placement/availability-zone")
	return ($az.Substring(0, ($az.Length -1)))
}

### Uses AWS CLI to push metrics to cloudwatch.###
function Put-InstanceData {
    param ([parameter(Valuefrompipeline=$true)] $metric_list)
    begin {
        $metric_data_list = New-Object System.Collections.ArrayList
    }
    process {
        if ($metric_list) {
            Write-Output "$metric_list will be pushed to cloudwatch"
	        $metric_data_list.Add($metric_list) | Out-Null
        }
    }
    end {
	    if ($metric_data_list.count -gt 0) {
            Write-Verbose "Putting CloudWatch metric data"
            $region = Get-InstanceRegion

            $AWSCLI='C:\Program Files\Amazon\AWSCLI\aws.exe'
            $metric_list_string = ""
            foreach($ml in $metric_data_list){
                $metric_list_string = """" + $ml + """"
                &$AWSCLI cloudwatch put-metric-data --namespace "System/Windows" --metric-data $metric_list_string --region $region
            }
            Write-Verbose "Done!"
        }
        else {
            throw "No metric data to push to CloudWatch exiting script" 
        }
    }
}


### Global trap for all exceptions for this script. All exceptions will exit the script.###
trap [Exception] {
    Report-Message ($_.Exception.Message)
    Exit
}

if ($version) {
    Report-Message "$scriptname version $ver"
    exit 
}

### Avoid a storm of calls at the beginning of a minute.###
if ($from_scheduler) {
	$rand = new-object system.random
	start-sleep -Seconds $rand.Next(20)
}
