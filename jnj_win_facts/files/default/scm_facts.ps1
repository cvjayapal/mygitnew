# *********************************************************************************************
# NAME:   scm_facts.ps1
#
# AUTHOR: Robert Laskowski & Brian Hurley
# DATE :  11/15/2015
#
# This script collects the facts about the system based on the avaialable metadata and sets
# local environment variables and puppet facts
#
# SYNTAX: scm_facts.ps1
#
# *********************************************************************************************
#$VerbosePreference = "continue"
$JnJFolder  = "C:\ProgramData\JnJ"
$nullvar    = "NotSet"

# *********************************************************************************************
#  Function: RunningAsAdministrator
#  Hosting Platform: ALL
#
#  Determines who is running this script, if exectuted in required Windows Administrator mode
#
#  na\admin_bhurley is sometimes in Administrator mode. Localhost\AdminNCS is always.
#  Built-in Local System Account ("NT AUTHORITY\System") is more powerful than Administrator.
#
#  Mandatory Integrity Control (MIC) was added in Windows Server 2008
#     SID: S-1-16-12288
#     Name: High Mandatory Integrity Level   (only System has higher level of trustworthiness)
#     Description: A high integrity level.
#
# *********************************************************************************************
function RunningAsAdministrator()
{
  $ScriptRunner = ""
  $ScriptRunner = (Invoke-Expression "whoami")

  $ScriptRunnersMode = ""
  $ScriptRunnersMode = (Invoke-Expression "whoami /groups | findstr /i /l S-1-16-12288  ")

  If ($ScriptRunnersMode)
  {
    write-log "Script executed by $ScriptRunner running in Windows Administrator mode."
  }
  Else
  {
    write-log "Script executed  $ScriptRunner is NOT running in Windows Administrator mode."
  }
}

# *********************************************************************************************
#  Function: write-log
#  Hosting Platform: ALL
# *********************************************************************************************
function write-log ($message)
{
  Write-Host $message
}

# *********************************************************************************************
#  Function: StringIsNullOrBlank()
#  Hosting Platform: All
#
#  This StringIsNullOrBlank() function Determines is the input $string is null or empty
# ********************************************************************************************
function StringIsNullOrBlank([string]$string)
{
  try
  {
    return [string]::IsNullOrWhiteSpace($string)
  }
  catch
  {
    $Error.Clear()
    return [string]::IsNullOrEmpty($string)
  }
}

# *********************************************************************************************
#  Function: CallAPI()
#  Hosting Platform: All
#
#  This CallAPI() function uses Invoke-WebRequest command to fetch content from given URL.
#    Invoke-WebRequest requires PowerShell 4 or above.  In the event (Windows 2008) when PS5
#    is not available, this function will fall back to using curl.exe.
#
#  URL Content is returned as String.
#    Normalized to remove CR and trailing spaces.
#    404 Status returns "404 - Not Found" string
# ********************************************************************************************
$ErrorNotFound = "404 - Not Found"
function CallAPI($apiURL, [bool]$critical = $false)
{
  write-log "Calling $apiURL"

  $try = 0
  while (1)
  {
    Try
    {
      if (Get-Command Invoke-WebRequest -errorAction SilentlyContinue)
      {
        [string]$apiData=(Invoke-WebRequest -Uri $apiURL -TimeoutSec 60 -UseBasicParsing).Content;
      }
      else
      {
        [string]$apidata = & 'C:\Windows\curl.exe' -s @($apiURL)
        if ($apidata -like "*$($ErrorNotFound)*")
        {
          return $ErrorNotFound
        }
        else
        {
          $apidata = $apidata.Trim().Replace(" ", "`n")
        }
      }
      if($critical -eq $false -or (StringIsNullOrBlank $apiData) -eq $false) {
        $apiData = $apiData.Trim().Replace("`r", "`n").Replace("`n`n", "`n")
        if(!($apiData -like "*ERROR*")) {
            return $apiData
        }
      }
    }
    Catch
    {
      $Error.Clear()
      if ($_.Exception.Response.StatusCode.Value__ -eq 404)
      {
        return $ErrorNotFound
      }
      write-log "Error calling $apiURL. $_"

      # TEMPORARY
      # Azure API change
      # Error: "All the required parameters were not specified to call the API. Please make sure that values for following parameters are present in the url pattern or query string:
      #           Required parameters:['ipaddress']optional parameters:[]
      #           default values for optional parameters:[]"
      if ($HostingPlatform -eq 'AZR')
      {
        $errText = $_.Exception.Message
        if ($errText -like '*Bad Request*' -or $errText -like '*ipaddress*')
        {
          # Call URL again with old ipaddress parameter
          $apiURL = $apiURL.replace("?ip_address", "?ipaddress")
          write-log ("API Error: Retrying with URL - " + $apiURL)
          return CallAPI $apiURL $critical
        }
      }
      # TEMPORARY
    }

    if ($critical)
    {
      if ( $try++ -ge 5 )
      {
        write-log "Unable to invoke API URL - $apiURL"
        return $ErrorNotFound
      }
    }
    else
    {
      break
    }

    write-log "Retrying $apiURL after 1 second..."
    start-sleep -s 1
  }

  # not found response
  return $ErrorNotFound
}


# *********************************************************************************************
#  Function: getCreds()
#  Hosting Platform: AWS Only
#
#  This getCreds() function Determines is the server has IMA role attached.
#    IF IAM Role attached function is skipped
#    IF no IAM Role attadhed curl is used to retrieve AWS Access Key & Secret from xbot metadata
#
#  Function then creates 1 directory (.aws), 1 file therein (config), and writes 4-line content:
#   C:\Users\admin_bhurley\.aws\config
#
#   [default]
#   aws_access_key_id = AKxxxxxxxxxxxxxxxxxxx
#   output = text
#   aws_secret_access_key = 7Jyxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
# ********************************************************************************************
function getCreds()
{
  write-log "Calling get-creds"
  if ($InstanceRole -eq "none")   #RLEDIT - add logic to ensure environment is AWS
  {
    #write-log "VPCPrefix environment variable in getcreds() is: "$env:vpcxprefix
    #write-log "VPCPrefix variable in getcreds() is: $vpcxprefix"
    write-log "Server IAM Role is none. Executing getCreds function."
    $apiURL = "http://" + $vpcxprefix + "api.vpcx.jnj.com/account/metric-reporter?ip_address=" + $IPAddress
    [string]$apidata = CallAPI $apiURL $true
    if ($apidata -ne $ErrorNotFound)
    {
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
      &$AWSCLI configure set region $Region
    }
    else
    {
      write-log "AWS Credentials not found. Response $apidata"
    }
  }
  else
  {
    write-log "Server IAM Role is $InstanceRole. Skipping getCreds function."
  }
}

# ********************************************************************************************
#  Define function: getTags()
#  Hosting Platform: AWS, Azure(to be implemented)
#
#  Using Hosting Platform API retriews the tags assigned to the server instance
#
#  Creates 1 file "$currentDir\instance_tags.txt" with following 5 tab-delimited fields:
#    TAGS  Name  i-780f8d89  instance
# ********************************************************************************************
function getTags()
{
  write-log "Calling get-tags"
  #write-log "Region environment variable in getTags() is: "$env:aws_region
  #write-log "Region Global variable in getTags() is: $Region"

  $awsResult = powershell -command "& {&'C:\Program Files\Amazon\AWSCLI\aws.exe' --region $Region ec2 describe-tags --filter 'Name=resource-id,Values=$InstanceID' --output text > $JnJFolder\SCM_facts_log\instance_tags.txt}" 2>&1

  write-log "Describe Tags response: $awsResult"
}

# ********************************************************************************************
#  Define function: getEnvironmentFromRole()
#  Hosting Platform: AWS, Azure
#
#  Using IAM Role (AWS) or Resource Group (AZR)  produce the puppet environment name
# ********************************************************************************************
function getEnvironmentFromRole([string] $Account, [string] $Role, $RolePartsLen, $IndexBranch)
{
  # AWS 'IAM Role' looks like 'itx-021-app-apdevelopment-developmentRole-VZBYXI5XE9A'
  # Azure 'resourcegroup' looks like 'AZR-ABP-xbot-Production'   (-app-  or -scm- parts not present)
  # OPC 'role' looks like 'OPC-account-app-branch'   (-app-  or -scm- parts not present)

  $parts=$Role.Split('-')
  if ($parts.length -ne $RolePartsLen)
  {
    $Role="none"
  }

  if ($Role -eq "none")
  {
    $Application="UnManagedApplication"
  }
  elseif ($parts.length -eq $RolePartsLen)
  {
    $AppOrSCM=$parts[2]
    $IndexApp = $IndexBranch - 1
    $AppBranch=$parts[$IndexBranch].TrimEnd("Role")
    if ($parts[$IndexApp] -eq "itscore")
    {
      $Application="its_core"
      $Environment=$Application + "_" + $AppBranch
    }
    elseif ($parts[$IndexApp] -eq "itscorepuppetmaster")
    {
      $Application="its_core_puppetmaster"
      $Environment=$Application + "_" + $AppBranch
    }
    else
    {
      $Application=$parts[$IndexApp]
      $Environment=$parts[0] + "_" + $parts[1] + "_" + $Application + "_" + $AppBranch
    }
  }
  else
  {
    $Application="WrongApplication"
  }

  # default to production for unmanaged application
  # development for DVL
  if ($Application -eq "UnManagedApplication" -or $Application -eq "WrongApplication")
  {
    # AppBranch
    if ($Account.StartsWith("0"))
    {
      $AppBranch="development"
    }
    else
    {
      $AppBranch="production"
    }

    # Environment
    $Environment="its_core_" + $AppBranch
  }

  $EnvironmentInfo = @{}
  $EnvironmentInfo['AppOrSCM']    = $AppOrSCM
  $EnvironmentInfo['Application'] = $Application
  $EnvironmentInfo['AppBranch']   = $AppBranch
  $EnvironmentInfo['Environment'] = $Environment
  return $EnvironmentInfo
}

# ********************************************************************************************
#  Define function: getCoreBranch()
#  Hosting Platform: All
#
#  Determine the branch of its_core to use for enforcement
# ********************************************************************************************
function getCoreBranch([string] $Account, [string] $Application, [string] $AppBranch)
{
  if ($AppBranch -eq "production" -or $AppBranch -eq "master")
  {
    return "production"
  }

  elseif ($AppBranch -eq "qa" -or $AppBranch -eq "staging")
  {
    return "qa"
  }

  elseif ($AppBranch -eq "development" -or $AppBranch -eq "test")
  {
    return "development"
  }

  elseif ($AppBranch -eq "experimental")
  {
    # For ITx-008 account allow experimental branch
    if ($Application -eq "its_core" -or $Account -like "00[08]")
    {
      return "experimental"
    }
    else
    {
      return "development"
    }
  }

  # AppBranch not (development, qa, production or experimental)
  elseif ($Account.StartsWith("0"))
  {
    # Default to development
    return "development"
  }

  # Default to production
  return "production"
}

# ********************************************************************************************
#  Define function: publishFact()
#  Hosting Platform: All
#
#  Publish fact to both output and Environment
# ********************************************************************************************
function publishFact([string] $Name, $Value)
{
  [Environment]::SetEnvironmentVariable($Name,$Value,"Machine")
  Write-Output "$Name=$Value"
}

# ********************************************************************************************
#  Define function: getPlatform()
#  Hosting Platform: All
#
#  Determine cloud platform from IPAddress
# ********************************************************************************************
function getPlatform([string] $IPAddress)
{
  $octets=$IPAddress.Split('.')
  $str=$octets[0] + '.' + $octets[1]

  # AWS Subnets
  if (($str -eq '10.37') -or ($str -eq '10.157') -or ($str -eq '10.221'))
  {
    return 'AWS'
  }

  # Azure Subnets
  if (($str -eq '10.67') -or ($str -eq '10.179') -or ($str -eq '10.215'))
  {
    return 'AZR'
  }

  elseif ($octets[0] -eq '10')
  {
    return 'OPC'
  }

  write-log "Could not detect the hosting platform from $IPAddress"
  return "NotSet"
}


#  ********************************************************************************************
#  SCM_Facts procedure begins here
#  ********************************************************************************************

  ### Set system variables
  $Name_of_This_Script = "scm_facts.ps1"
  $datetime = get-date -format "dd-MMM-yyyy HH:mm:ss"
  $TimeZone = invoke-command {tzutil /g}

  write-log "Started script: $Name_of_This_Script at $datetime $TimeZone"
  RunningAsAdministrator

  # Operating System
  $OperatingSystem = (Get-WmiObject Win32_OperatingSystem).Caption
  write-log "Operating System - $OperatingSystem"

  # IP Address
  if ($OperatingSystem -like "*Windows Server 2012*")
  {
    $IPAddress = (get-netadapter | get-netipaddress | Sort-Object InterfaceIndex | ? addressfamily -eq 'IPv4').IPAddress | Select-Object -First 1
  }
  elseif ($OperatingSystem -like "*Windows Server 2008*")
  {
    $IPAddress = (Get-WmiObject -class win32_NetworkAdapterConfiguration -Filter 'ipenabled = "true"' | Sort-Object InterfaceIndex | Select-Object -First 1).IPAddress[0]
  }
  write-log "IP Address - $IPAddress"

  # Platform
  $HostingPlatform = getPlatform $IPAddress
  write-log "Hosting Platform - $HostingPlatform"

  # Is VPC?
  $IsVPCx = ($HostingPlatform -ne "OPC")

  # Determine Global environment prefix
  $ServerEnvironment  = [Environment]::GetEnvironmentVariable('vpcx_vpcxenvironment', "Machine")
  if (StringIsNullOrBlank($ServerEnvironment))
  {
    if ($IsVPCx -eq $true)
    {
      switch -regex ($env:computername.Substring(3,3).ToLower()) {
        "[0-9]+"  { $ServerEnvironment = 'Development'; break }
        "aba"     { $ServerEnvironment = 'QA'         ; break }
        "abe"     { $ServerEnvironment = 'QA'         ; break }
        "aca"     { $ServerEnvironment = 'QA'         ; break }
        "acb"     { $ServerEnvironment = 'QA'         ; break }
         default  { $ServerEnvironment = 'Production' }
      }
    }
    else
    {
      # TODO - but for now OPCx == Development
      $ServerEnvironment = 'Development'
    }
  }

  # VPCx Facts Cache
  $FactsFolder     = "$JnJFolder\vpcx_facts"
  if (!(Test-Path $FactsFolder)) {New-Item -ItemType Directory -Path $FactsFolder}

  # VPCxPrefix (dvl-, qa-, <empty for prod>)
  if ($ServerEnvironment -eq "Development")
  {
    $vpcxprefix="dvl-"
  }
  elseif ($ServerEnvironment -eq "QA")
  {
    $vpcxprefix="qa-"
  }
  else
  {
    $vpcxprefix=""
  }
  write-log "Server Environment is $ServerEnvironment"

  # VPCxPrefix
  $vpcxprefix_file = $FactsFolder + "\vpcxprefix.txt"
  "vpcxprefix",$vpcxprefix -join '=' | Out-File -FilePath $vpcxprefix_file -Encoding ascii
  publishFact "vpcxprefix" $vpcxprefix

  # SCM Build Type
  $scm_buildtype = (Get-ItemProperty -ErrorAction SilentlyContinue -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\JNJ\Server" -Name "scm_buildtype")."scm_buildtype"
  if(StringIsNullOrBlank($scm_buildtype)) { $scm_buildtype = $nullvar }
  publishFact "scm_buildtype" $scm_buildtype

  # *****************************************************************************
  # Init Environment
  # *****************************************************************************
  if ($HostingPlatform -eq 'AWS')
  {
    $env:Path = $env:Path + ";C:\Program Files\Amazon\AWSCLI\;C:\Users\AdminNCS\.aws;C:\Users\Administrator\.aws"

    # xbot endpoint hostname
    $xBot_API_Endpoint = $vpcxprefix + "api.vpcx.jnj.com"

    # xbot endpoint urls
    $xBot_API_Hostname = "http://" + $xBot_API_Endpoint + "/instance/name?ip_address=" + $IPAddress
    $xBot_API_Info     = "http://" + $xBot_API_Endpoint + "/instance/info?ip_address=" + $IPAddress
  }

  if ($HostingPlatform -eq 'AZR')
  {
    $env:Path = $env:Path + ";C:\Users\AdminNCS\.azr;C:\Users\Administrator\.azr"

    # xbot endpoint hostname
    $xBot_API_Endpoint = @{$true="10.67.0.4";$false="10.67.8.4"}[$ServerEnvironment -eq "Development"]

    # xbot endpoint urls
    $xBot_API_Hostname = "http://" + $xBot_API_Endpoint + "/instance/name?ip_address=" + $IPAddress
    $xBot_API_Info     = "http://" + $xBot_API_Endpoint + "/instance/info?ip_address=" + $IPAddress
  }

  # *****************************************************************************
  # Pull VPCx Facts
  # *****************************************************************************
  if ($IsVPCx -eq $true)
  {
    ### Retrieve Instance API info and set as vpcx_ facts
    $keyPrefix    = "vpcx_"
    $InfoValues   = ""

    $vpcxValues   = CallAPI $xBot_API_Info $true
    if ($vpcxValues -ne $ErrorNotFound)
    {
      $InfoValues   = $vpcxValues.ToLower().Replace(" ", "`n").Replace("ssh-rsa`n", "ssh-rsa ").Split("`n")
    }
  }
  else
  {
    ### Retrieve Instance info and set as opcx_ facts
    $keyPrefix    = "opcx_"
    $InfoValues   = ""

    if (Test-Path "$JnJFolder\instance_facts.txt")
    {
      $opcxValues = Get-Content "$JnJFolder\instance_facts.txt"
      $InfoValues = $opcxValues.ToLower().Replace("ssh-rsa`n", "ssh-rsa ").Split("`n")
    }
  }

  # If no information was retrieved
  if ($InfoValues -eq "")
  {
    # Basic Facts required, defaults will be added later
    $basicValues  = "environment:$($ServerEnvironment)`nregion:`nhostname:$($env:COMPUTERNAME)`ngxp:false`nsox:false`ndmz:false"
    if ($IsVPCx -eq $true)
    {
      $basicValues  = "vpcxenvironment:$($ServerEnvironment)`n$($basicValues)"
      $basicValues  = "alertlogickey:`nalertlogiccid:`n$($basicValues)"
      if ($HostingPlatform -eq 'AZR')
      {
        $basicValues= "resourcegroup:none`n$($basicValues)"
      }
    }
    $InfoValues   = $basicValues.ToLower().Split("`n")
  }

  # For all info: parse, cache and publish
  foreach ($Line in $InfoValues)
  {
    if (StringIsNullOrBlank($Line)) { continue }

    # Split value
    $Values = $Line.Split(":")

    if ($Values.Count -gt 1)
    {
      # Remove prefix from name
      $FactName   = $Values[0].Replace($keyPrefix, "")
      $FactValue  = $Values[1]
      switch ($FactName)
      {
        "linuxadminpublickey"                 { if($FactValue -notlike "ssh-rsa AAAA*"){continue} }
        "alertlogickey"                       {
          if(StringIsNullOrBlank($FactValue) -and $HostingPlatform -eq 'AZR') { $FactValue = "bedf42b54ba750b97bda6062790e9029e9b344e56b32498266" }
        }
        "alertlogiccid"                       {
          if(StringIsNullOrBlank($FactValue) -and $HostingPlatform -eq 'AZR') { $FactValue = "33376" }
        }
        "awsaccountid"                        {
          if(StringIsNullOrBlank($FactValue)) { $FactValue = $nullvar }
        }
        "region"                              {
          if(StringIsNullOrBlank($FactValue)) { $FactValue = "us-east-1" }

          #Azure
          #NA - eastus, eastus2
          #EU - westeurope, northeurope
          #AP - southeastasia, eastasia
          $region     = $FactValue.ToLower();
          if($region -like '*eastus*')  {  $region = "us-east-1"      }
          if($region -like '*europe*')  {  $region = "eu-west-1"      }
          if($region -like '*eastasia*'){  $region = "ap-southeast-1" }

          #OPC
          if($region -like 'na')        {  $region = "us-east-1"      }
          if($region -like 'eu')        {  $region = "eu-west-1"      }
          if($region -like 'ap')        {  $region = "ap-southeast-1" }

          $FactValue  = $region
        }
        "accountid"                           { if($FactValue -notmatch "itx-.*|azr-.*|opc-.*")  { continue } }
        "hostname"                            { if($FactValue -notmatch "aws.*|azr.*|its.*")     { continue } }
        "vpcxenvironment"                     { if(StringIsNullOrBlank($FactValue))              { $FactValue = $ServerEnvironment.ToLower() } }
        "environment"                         { if(StringIsNullOrBlank($FactValue))              { $FactValue = $ServerEnvironment.ToLower() } }
        "gxp"                                 { if($FactValue -notmatch "true|false")            { $FactValue = "false" } }
        "sox"                                 { if($FactValue -notmatch "true|false")            { $FactValue = "false" } }
        "dmz"                                 { if($FactValue -notmatch "true|false")            { $FactValue = "false" } }
        "legalhold"                           { if($FactValue -notmatch "true|false")            { $FactValue = $nullvar} }

        # default nullvar
        default                               { if(StringIsNullOrBlank($FactValue))              { $FactValue = $nullvar}}
      }

      # Write fact to a file
      "$($FactName)=$($FactValue)" | Out-File "$FactsFolder\$($keyPrefix)$($FactName)" -Encoding ascii
    }
  }

  # *****************************************************************************
  # Publish VPCx Facts
  # *****************************************************************************
  # Hostname
  # eg. aws000nva1011 or azr000nva1011
  #$Hostname = CallAPI $xBot_API_Hostname $true
  $Hostname = $env:COMPUTERNAME

  # For every fact locally cached, publish it
  $vpcxFacts = @{}
  foreach ($file in (Get-ChildItem -Path $FactsFolder -Filter "$($keyPrefix)*.*"))
  {
    $Line = Get-Content $file.FullName
    $Values = $Line.Split("=")
    if ($Values.count -eq 2)
    {
      $Values[0] = $Values[0].Replace('vpcx_', '')
      publishFact "$($keyPrefix)$($Values[0])" $Values[1]

      # Create 'vpcx_' fact for non VPC environments for backward compatibility
      if ($IsVPCx -ne $true)
      {
        publishFact "vpcx_$($Values[0])" $Values[1]
        if ($Values[0] -eq "environment")
        {
          publishFact "vpcx_vpcx$($Values[0])" $Values[1]
        }
      }

      $vpcxFacts[$Values[0]] = $Values[1]
    }

    # Hostname
    if ($Values[0] -eq "hostname")
    {
      $Hostname = $Values[1]
    }
  }
  write-log "Hostname - $Hostname"

  # SCM Hostname and IPAddress
  publishFact "scm_ipaddress" $IPAddress
  publishFact "scm_hostname" $Hostname

  # *****************************************************************************
  # Gather Environment Details
  # *****************************************************************************

  # Account
  $Account = $Hostname.SubString(3,3).ToLower();

  # IAM / Resource Group
  if ($HostingPlatform -eq 'AZR')
  {
    # Region from xBot
    $Region           = $vpcxFacts.Get_Item("region").ToLower();

    # Instance-id
    $InstanceID       = (Get-WmiObject -class Win32_ComputerSystemProduct -namespace root\CIMV2).UUID.ToString()

    # Resource Group
    $ResourceGroup    = $vpcxFacts.Get_Item("resourcegroup").ToLower();

    ### Determine server application environment
    $EnvironmentInfo  = getEnvironmentFromRole -Account $Account -Role $ResourceGroup -RolePartsLen 4 -IndexBranch 3
  }

  if ($HostingPlatform -eq 'AWS')
  {
    $MetaDataURL      = "http://169.254.169.254/latest/meta-data"

    # Region from AWS
    $RegionAZ         = CallAPI ($MetaDataURL + "/placement/availability-zone/") $true
    $Region           = $RegionAZ.SubString(0, $RegionAZ.Length-1)

    # Instance-id
    $InstanceID       = CallAPI ($MetaDataURL + "/instance-id") $true

    # IAM Role
    $InstanceRole     = CallAPI ($MetaDataURL + "/iam/security-credentials/") $true
    if ($InstanceRole -eq $ErrorNotFound)
    {
      $InstanceRole   = "none"
    }

    ### Determine server application environment
    $EnvironmentInfo  = getEnvironmentFromRole -Account $Account -Role $InstanceRole -RolePartsLen 6 -IndexBranch 4
  }

  # TODO - Implement when OCPx Method is available - for now hard code
  if ($HostingPlatform -eq 'OPC')
  {
    # use '000000' for account
    $Account          = $vpcxFacts.Get_Item("accountid").ToLower().Replace("opc-", "");

    # Region
    $Region           = $vpcxFacts.Get_Item("region").ToLower();

    # Instance-id
    $InstanceID       = (Get-WmiObject -class Win32_ComputerSystemProduct -namespace root\CIMV2).UUID.ToString()

    # OPC 'role' looks like 'OPC-account-app-branch'   (-app-  or -scm- parts not present)
    $InstanceRole     = "opc-" + $Account + "-" + $vpcxFacts.Get_Item("application").ToLower() + "-" + $vpcxFacts.Get_Item("appbranch").ToLower()

    ### Determine server application environment
    $EnvironmentInfo  = getEnvironmentFromRole -Account $Account -Role $InstanceRole -RolePartsLen 4 -IndexBranch 3
  }

  # Publish SCM Facts
  $AppOrSCM    = $EnvironmentInfo['AppOrSCM']
  $Application = $EnvironmentInfo['Application']
  $AppBranch   = $EnvironmentInfo['AppBranch']
  $Environment = $EnvironmentInfo['Environment']

  ### Determine mapping of Application branch (environment) to ITS_Core Branch (environment)
  $CoreBranch  = getCoreBranch -Account $Account -Application $Application -AppBranch $AppBranch

  ## S3 App bucket s3:// url
  if ($false -eq ($Application -eq "UnManagedApplication" -or $Application -eq "WrongApplication")) {
    $S3AppStorage = "s3://itx-" + $Account + "-" + $AppOrSCM + "-" + $Application + "/" + $AppBranch
  } else {
    $S3AppStorage = $nullvar
  }

  # vpcx bucket https:// url
  $S3VpcxPackages = "https://s3.amazonaws.com/jnj-" + $vpcxprefix + "vpcx-scm/packages"

  # *****************************************************************************
  # Publish SCM Facts
  # *****************************************************************************
  publishFact "scm_account" $Account
  publishFact "scm_appbranch" $AppBranch
  publishFact "scm_application" $Application
  publishFact "scm_appstorage" (@{$true=$S3AppStorage;$false=$nullvar}[$HostingPlatform -eq 'AWS'])
  publishFact "scm_aws_iam_role" (@{$true=$InstanceRole;$false=$nullvar}[$HostingPlatform -eq 'AWS' -and $InstanceRole -ne $null -and $InstanceRole -ne 'none'])
  publishFact "scm_azure_resourcegroup" (@{$true=$ResourceGroup;$false=$nullvar}[$ResourceGroup -ne $null])
  publishFact "scm_opc_role" (@{$true=$InstanceRole;$false=$nullvar}[$HostingPlatform -eq 'OPC' -and $InstanceRole -ne $null -and $InstanceRole -ne 'none'])
  publishFact "scm_corebranch" $CoreBranch
  publishFact "scm_environment" $Environment
  publishFact "scm_hosting_platform" $HostingPlatform
  publishFact "scm_iam_role" (@{$true=$InstanceRole;$false=$nullvar}[$HostingPlatform -eq 'AWS' -and $InstanceRole -ne $null -and $InstanceRole -ne 'none'])
  publishFact "scm_instance_id" $InstanceID
  publishFact "scm_packages" $S3VpcxPackages
  publishFact "scm_region" $Region

  # *****************************************************************************
  # SCM-837 - EnableUAC
  # *****************************************************************************
  $uac_enable = "true"
  if (Test-Path "C:\JnJServerBuild-Windows")
  {
    $build_in_progress = "true"

    # Build is in progress, check how far along it is, must be on or after phase5
    $PhasesControlFile = "C:\JnJServerBuild-Windows\BuildWorkflow\SCM_Workflow_Phases_Control.json"
    if (Test-Path $PhasesControlFile)
    {
      $PhasesControlContent = (Get-Content $PhasesControlFile) -join "`n"
      $PhasesControl=ConvertFrom-Json -InputObject $PhasesControlContent -Verbose
      if ($PhasesControl."PhaseV".LastScript -eq "None")
      {
        # phase 5 has not yet started
        $uac_enable = "false"
      }
    }
    Write-Output "scm_build_in_progress=$build_in_progress"
  }
  publishFact "scm_uac_enable" $uac_enable

  # *****************************************************************************
  # AWS Tags
  # *****************************************************************************
  if ($HostingPlatform -eq 'AWS')
  {
    # Backward compatibility
    publishFact "aws_account" $Account
    publishFact "aws_appbranch" $AppBranch
    publishFact "aws_application" $Application
    publishFact "aws_corebranch" $CoreBranch
    publishFact "aws_environment" $Environment
    publishFact "aws_iam_role" $InstanceRole
    publishFact "aws_instance_id" $InstanceID
    publishFact "aws_region" $Region

    ### Find file of cached SCM tags (if file exists), and examine content
    $cached_tag_file_path = "C:\ProgramData\PuppetLabs\facter\facts.d"
    $cached_tag_file_name = "scm_tags"
    $cached_tag_file = $cached_tag_file_path + "\" + $cached_tag_file_name
    if (test-path $cached_tag_file) {
      write-log "Cached tag file $cached_tag_file_name does exist."
      $cached_tags = $(Get-Content $cached_tag_file | Out-String).ToLower()
      $cached_tags_line_count = (Get-Content $cached_tag_file | Measure-Object -Line).lines
    }
    else
    {
      write-log "Cached tag file $cached_tag_file_name does not exist."
    }

    ### Get Tags assigned to this server instance
    $currentDir = "$JnJFolder\SCM_Facts_Log"
    if (!(Test-Path "$currentDir")) { new-item "$currentDir" -ItemType Directory }

    $scm_tags_file = $currentDir + "\instance_tags.txt"
    if (-Not (Test-Path $scm_tags_file))
    {
      getCreds
      getTags
    }
    if (Test-Path $scm_tags_file)
    {
      ### Retrieve Instance Tags and set aws/scm_tag_ facts
      $reader = [System.IO.File]::OpenText($scm_tags_file)
      try
      {
        for(;;)
        {
          $line = $reader.ReadLine()
          if ($line -eq $null) { break }
          $lineSplit = $line.Replace("`t", ",").Split(',')
          $newTag_aws = "aws_tag_" + $lineSplit[1].ToLower()
          $newTag_scm = "scm_tag_" + $lineSplit[1].ToLower()
          $newValue   = $lineSplit[4].ToLower()
          if ($cached_tags -notlike "*$newTag_aws=*")
          {
            write-log "Set $newTag_aws to value $newValue (Note: Tag not previously cached)"
            publishFact $newTag_aws $newValue
          }
          else
          {
            write-log "This tag ($newTag_aws, with value = $newValue) WAS 1 of the $cached_tags_line_count lines in cached tag file $cached_tag_file_name ($cached_tags), so will NOT update value to $newValue."
            Write-Output "$newTag=$newValue"
          }

          if ($cached_tags -notlike "*$newTag_scm=*")
          {
            write-log "Set $newTag to value $newValue (Note: Tag not previously cached)"
            publishFact $newTag_scm $newValue
          }
          else
          {
            write-log "This tag ($newTag_scm, with value = $newValue) WAS 1 of the $cached_tags_line_count lines in cached tag file $cached_tag_file_name ($cached_tags), so will NOT update value to $newValue."
            write-Output "$newTag_scm=$newValue"
          }
        }
      }
      finally
      {
        $reader.Close()
      }
      Remove-Item $scm_tags_file
    }
  }

  $datetime = get-date -format "dd-MMM-yyyy HH:mm:ss"
  write-log "Finished script: $Name_of_This_Script at $datetime $TimeZone"
