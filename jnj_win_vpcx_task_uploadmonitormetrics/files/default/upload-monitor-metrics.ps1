[CmdletBinding(SupportsShouldProcess = $true)]
param (
    [switch]$bypassFIPSValidation = $true
)

$creds_file = "C:\Windows\System32\config\systemprofile\.aws\credentials"

$scriptpath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Write-Verbose "Script is in path $scriptpath"

$mon_shared = Join-Path $scriptpath "mon-shared.ps1"
. $mon_shared

if (($env:aws_iam_role -eq "none") -or ($env:aws_iam_role -eq $null)){
    if ( (-Not (test-path -Path $creds_file)) -or ( (get-childitem $creds_file).LastWriteTime -lt (get-date).AddMinutes(-30) ) ) {
        # File not found or is more than 30 mins old, so update it.
        # This caching is enough to cover a temporary inability to access
        # the credentials, but not long enough to cause false alarm failures
        # if the credentials are cached too long (e.g. 1 hour).
        # Check if prod system, otherwise it's dev
        $webclient = New-Object System.Net.WebClient
        $server_account_id = [string]$env:computername.substring(3,3).ToLower()
        switch -regex ($server_account_id) {
            "[0-9]+" { $url = "http://dvl-api.vpcx.jnj.com/account/metric-reporter"; break }
            "aba"    { $url = "http://qa-api.vpcx.jnj.com/account/metric-reporter"; break }
            "abe"    { $url = "http://qa-api.vpcx.jnj.com/account/metric-reporter"; break }
            "aca"    { $url = "http://qa-api.vpcx.jnj.com/account/metric-reporter"; break }
            "acb"    { $url = "http://qa-api.vpcx.jnj.com/account/metric-reporter"; break }
            default  { $url = "http://api.vpcx.jnj.com/account/metric-reporter" }
        }
        $url = $url + "?ip_address=" + (Get-InstanceMetadata("/local-ipv4"))
        $region = Get-InstanceRegion
        write-output "Downloading credentials from $url..."
        [string]$apidata = $webclient.DownloadString($url)
        if ($apidata -ne $ErrorNotFound){
          $apidataSplit = $apidata.Split("`n")
          $AWSAccessKeyId = $apidataSplit[0]
          $AWSSecretKey = $apidataSplit[1]
          $AWSAccessKeyId = $apidataSplit[0].Replace("AWSAccessKeyId=", "")
          $AWSSecretKey =$apidataSplit[1].Replace("AWSSecretKey=", "")

          # Use cli to configure, configuration already exists by bootstrap. Update the pieces needed.
          $AWSCLI='C:\Program Files\Amazon\AWSCLI\aws.exe'
          &$AWSCLI configure set aws_access_key_id $AWSAccessKeyId
          &$AWSCLI configure set aws_secret_access_key $AWSSecretKey
          &$AWSCLI configure set output text
          &$AWSCLI configure set region $region

        }
        else{
          write-log "AWS Credentials not found. Response $apidata"
        }
    }
    else {
        if (test-path $creds_file) {
            write-output "Using existing credentials in $creds_file."
        }
    }
}
else
{
    write-output "Server IAM Role is $($env:aws_iam_role).  AWS CLI configuration not required to set explicitly"
}

Write-Output "Upload memory metrics..."
$mem_script = Join-Path $scriptpath "mon-put-metrics-mem.ps1"
powershell.exe -Command "& \`"$mem_script\`" -mem_util -verbose"

write-output "Upload partition metrics..."
$disk_script = Join-Path $scriptpath "mon-put-metrics-partitions.ps1"
powershell.exe -Command "& \`"$disk_script\`" -vss_age -disk_space_util -verbose"

Write-Output "Script Complete."
