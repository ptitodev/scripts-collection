# Verify Running as Admin
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
If (-not $isAdmin) {
    Write-Host "-- Restarting as Administrator" -ForegroundColor Cyan ; Start-Sleep -Seconds 1

    if($PSVersionTable.PSEdition -eq "Core") {
        Start-Process pwsh.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs 
    } else {
        Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs 
    }

    exit
}

#region Functions
#region Output logging
function WriteInfo($message) {
    Write-Host $message
}

function WriteInfoHighlighted($message) {
Write-Host $message -ForegroundColor Cyan
}

function WriteSuccess($message) {
Write-Host $message -ForegroundColor Green
}

function WriteError($message) {
Write-Host $message -ForegroundColor Red
}

function WriteErrorAndExit($message) {
    Write-Host $message -ForegroundColor Red
    Write-Host "Press enter to continue ..."
    Stop-Transcript
    Read-Host | Out-Null
    Exit
}
#endregion

#region Telemetry
Function Merge-Hashtables {
    $Output = @{}
    ForEach ($Hashtable in ($Input + $Args)) {
        If ($Hashtable -is [Hashtable]) {
            ForEach ($Key in $Hashtable.Keys) {$Output.$Key = $Hashtable.$Key}
        }
    }
    $Output
}
function Get-StringHash {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline, Mandatory = $true)]
        [string]$String,
        $Hash = "SHA1"
    )
    
    process {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($String)
        $algorithm = [System.Security.Cryptography.HashAlgorithm]::Create($Hash)
        $StringBuilder = New-Object System.Text.StringBuilder 
      
        $algorithm.ComputeHash($bytes) | 
        ForEach-Object { 
            $null = $StringBuilder.Append($_.ToString("x2")) 
        } 
      
        $StringBuilder.ToString() 
    }
}

function Get-VolumePhysicalDisk {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Volume
    )

    process {
        if(-not $Volume.EndsWith(":")) {
            $Volume += ":"
        }

        $physicalDisks = Get-cimInstance "win32_diskdrive"
        foreach($disk in $physicalDisks) {
            $partitions = Get-cimInstance -Query "ASSOCIATORS OF {Win32_DiskDrive.DeviceID=`"$($disk.DeviceID.replace('\','\\'))`"} WHERE AssocClass = Win32_DiskDriveToDiskPartition"
            foreach($partition in $partitions) {
                $partitionVolumes = Get-cimInstance -Query "ASSOCIATORS OF {Win32_DiskPartition.DeviceID=`"$($partition.DeviceID)`"} WHERE AssocClass = Win32_LogicalDiskToPartition"
                foreach($partitionVolume in $partitionVolumes) {
                    if($partitionVolume.Name -eq $Volume) {
                        $physicalDisk = Get-PhysicalDisk | Where-Object DeviceID -eq $disk.Index
                        return $physicalDisk
                    }
                }
            }
        }
    }
}

function Get-TelemetryLevel {
    param(
        [switch]$OptOut
    )
    process {
        $acceptedTelemetryLevels = "None", "Basic", "Full"

        # LabConfig value has a priority
        if($LabConfig.TelemetryLevel -and $LabConfig.TelemetryLevel -in $acceptedTelemetryLevels) {
            return $LabConfig.TelemetryLevel
        }

        # Environment variable as a fallback
        if($env:WSLAB_TELEMETRY_LEVEL -and $env:WSLAB_TELEMETRY_LEVEL -in $acceptedTelemetryLevels) {
            return $env:WSLAB_TELEMETRY_LEVEL
        }

        # If nothing is explicitely configured and OptOut flag enabled, explicitely disable telemetry
        if($OptOut) {
            return "None"
        }

        # as a last option return nothing to allow asking the user
    }
}

function Get-TelemetryLevelSource {
    param(
        [switch]$OptOut
    )
    process {
        $acceptedTelemetryLevels = "None", "Basic", "Full"

        # Is it set interactively?
        if($LabConfig.ContainsKey("TelemetryLevelSource")) {
            return $LabConfig.TelemetryLevelSource
        }

        # LabConfig value has a priority
        if($LabConfig.TelemetryLevel -and $LabConfig.TelemetryLevel -in $acceptedTelemetryLevels) {
            return "LabConfig"
        }

        # Environment variable as a fallback
        if($env:WSLAB_TELEMETRY_LEVEL -and $env:WSLAB_TELEMETRY_LEVEL -in $acceptedTelemetryLevels) {
            return "Environment"
        }
    }
}

function Get-PcSystemType {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Id
    )
    process {
        $type = switch($Id) {
            1 { "Desktop" }
            2 { "Laptop" }
            3 { "Workstation" }
            4 { "Server" }
            7 { "Server" }
            5 { "Server" }
            default { $Id }
        }

        $type
    }
}

$aiPropertyCache = @{}

function New-TelemetryEvent {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Event,
        $Properties,
        $Metrics,
        $NickName
    )

    process {
        if(-not $TelemetryInstrumentationKey) {
            WriteInfo "Instrumentation key is required to send telemetry data."
            return
        }
        
        $level = Get-TelemetryLevel
        $levelSource = Get-TelemetryLevelSource

        $r = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion"
        $build = "$($r.CurrentMajorVersionNumber).$($r.CurrentMinorVersionNumber).$($r.CurrentBuildNumber).$($r.UBR)"
        $osVersion = "$($r.ProductName) ($build)"
        $hw = Get-CimInstance -ClassName Win32_ComputerSystem
        $os = Get-CimInstance -ClassName Win32_OperatingSystem
        $machineHash = (((Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Cryptography).MachineGuid) | Get-StringHash)

        if(-not $NickName) {
            $NickName = "?"
        }

        $osType = switch ($os.ProductType) {
            1 { "Workstation" }
            default { "Server" }
        }

        $extraMetrics = @{}
        $extraProperties = @{
            'telemetry.level' = $level
            'telemetry.levelSource' = $levelSource
            'telemetry.nick' = $NickName
            'powershell.edition' = $PSVersionTable.PSEdition
            'powershell.version' = $PSVersionTable.PSVersion.ToString()
            'host.isAzure' = (Get-CimInstance win32_systemenclosure).SMBIOSAssetTag -eq "7783-7084-3265-9085-8269-3286-77"
            'host.os.type' = $osType
            'host.os.build' = $r.CurrentBuildNumber
            'hw.type' = Get-PcSystemType -Id $hw.PCSystemType
        }
        if($level -eq "Full") {
            # OS
            $extraProperties.'device.locale' = (Get-WinsystemLocale).Name

            # RAM
            $extraMetrics.'memory.total' = [Math]::Round(($hw.TotalPhysicalMemory)/1024KB, 0)
            
            # CPU
            $extraMetrics.'cpu.logical.count' = $hw.NumberOfLogicalProcessors
            $extraMetrics.'cpu.sockets.count' = $hw.NumberOfProcessors

            if(-not $aiPropertyCache.ContainsKey("cpu.model")) {
                $aiPropertyCache["cpu.model"] = (Get-CimInstance "Win32_Processor" | Select-Object -First 1).Name
            }
            $extraProperties.'cpu.model' = $aiPropertyCache["cpu.model"]

            # Disk
            $driveLetter = $ScriptRoot -Split ":" | Select-Object -First 1
            $volume = Get-Volume -DriveLetter $driveLetter
            $disk = Get-VolumePhysicalDisk -Volume $driveLetter
            $extraMetrics.'volume.size' = [Math]::Round($volume.Size / 1024MB)
            $extraProperties.'volume.fs' = $volume.FileSystemType
            $extraProperties.'disk.type' = $disk.MediaType
            $extraProperties.'disk.busType' = $disk.BusType
        }

        $payload = @{
            name = "Microsoft.ApplicationInsights.Event"
            time = $([System.dateTime]::UtcNow.ToString("o")) 
            iKey = $TelemetryInstrumentationKey
            tags = @{ 
                "ai.internal.sdkVersion" = 'wslab-telemetry:1.0.1'
                "ai.application.ver" = $wslabVersion
                "ai.cloud.role" = Split-Path -Path $PSCommandPath -Leaf
                "ai.session.id" = $TelemetrySessionId
                "ai.user.id" = $machineHash
                "ai.device.id" = $machineHash
                "ai.device.type" = $extraProperties["hw.type"]
                "ai.device.locale" = "" # not propagated anymore
                "ai.device.os" = ""
                "ai.device.osVersion" = ""
                "ai.device.oemName" = ""
                "ai.device.model" = ""
            }
            data = @{
                baseType = "EventData"
                baseData = @{
                    ver = 2 
                    name = $Event
                    properties = ($Properties, $extraProperties | Merge-Hashtables)
                    measurements = ($Metrics, $extraMetrics | Merge-Hashtables)
                }
            }
        }

        if($level -eq "Full") {
            $payload.tags.'ai.device.os' = $osVersion
            $payload.tags.'ai.device.osVersion' = $build
        }
    
        $payload
    }
}

function Send-TelemetryObject {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Data
    )

    process {
        $json = "{0}" -f (($Data) | ConvertTo-Json -Depth 10 -Compress)

        if($LabConfig.ContainsKey('TelemetryDebugLog')) {
            Add-Content -Path "$ScriptRoot\Telemetry.log" -Value ((Get-Date -Format "s") + "`n" + $json)
        }

        try {
            $response = Invoke-RestMethod -Uri 'https://dc.services.visualstudio.com/v2/track' -Method Post -UseBasicParsing -Body $json -TimeoutSec 20
        } catch { 
            WriteInfo "`tSending telemetry failed with an error: $($_.Exception.Message)"
            $response = $_.Exception.Message
        }

        if($LabConfig.ContainsKey('TelemetryDebugLog')) {
            Add-Content -Path "$ScriptRoot\Telemetry.log" -Value $response
            Add-Content -Path "$ScriptRoot\Telemetry.log" -Value "`n------------------------------`n"
        }
    }
}

function Send-TelemetryEvent {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Event,

        $Properties,
        $Metrics,
        $NickName
    )

    process {
        $telemetryEvent = New-TelemetryEvent -Event $Event -Properties $Properties -Metrics $Metrics -NickName $NickName
        Send-TelemetryObject -Data $telemetryEvent
    }
}

function Send-TelemetryEvents {
    param(
        [Parameter(Mandatory = $true)]
        [array]$Events
    )

    process {
        Send-TelemetryObject -Data $Events
    }
}

function Read-TelemetryLevel {
    process {
        # Ask user for consent
        WriteInfoHighlighted "`nLab telemetry"
        WriteInfo "By providing a telemetry information you will help us to improve WSLab scripts. There are two levels of a telemetry information and we are not collecting any personally identifiable information (PII)."
        WriteInfo "Details about telemetry levels and the content of telemetry messages can be found in documentation https://aka.ms/wslab/telemetry"
        WriteInfo "Available telemetry levels are:"
        WriteInfo " * None  -- No information will be sent"
        WriteInfo " * Basic -- Information about lab will be sent (e.g. script execution time, number of VMs, guest OSes)"
        WriteInfo " * Full  -- Information about lab and the host machine (e.g. type of disk)"
        WriteInfo "Would you be OK with providing an information about your WSLab usage?"
        WriteInfo "`nTip: You can also configure telemetry settings explicitly in LabConfig.ps1 file or by setting an environmental variable and suppress this prompt."

        $options = [System.Management.Automation.Host.ChoiceDescription[]] @(
          <# 0 #> New-Object System.Management.Automation.Host.ChoiceDescription "&None", "No information will be sent"
          <# 1 #> New-Object System.Management.Automation.Host.ChoiceDescription "&Basic", "Lab info will be sent (e.g. script execution time, number of VMs)"
          <# 2 #> New-Object System.Management.Automation.Host.ChoiceDescription "&Full", "More details about the host machine and deployed VMs (e.g. guest OS)"
        )
        $response = $host.UI.PromptForChoice("WSLab telemetry level", "Please choose a telemetry level for this WSLab instance. For more details please see WSLab documentation.", $options, 1 <#default option#>)

        $telemetryLevel = $null
        switch($response) {
            0 {
                $telemetryLevel = 'None'
                WriteInfo "`nNo telemetry information will be sent."
            }
            1 {
                $telemetryLevel = 'Basic'
                WriteInfo "`nTelemetry has been set to Basic level, thank you for your valuable feedback."
            }
            2 {
                $telemetryLevel = 'Full'
                WriteInfo "`nTelemetry has been set to Full level, thank you for your valuable feedback."
            }
        }

        $telemetryLevel
    }
}

# Instance values
$ScriptRoot = $PSScriptRoot
$wslabVersion = "v21.09.3"
$TelemetryEnabledLevels = "Basic", "Full"
$TelemetryInstrumentationKey = "9ebf64de-01f8-4f60-9942-079262e3f6e0"
$TelemetrySessionId = $ScriptRoot + $env:COMPUTERNAME + ((Get-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\Cryptography).MachineGuid) | Get-StringHash
#endregion
#endregion

#region Do some clenaup
    #Start
        $StartDateTime = Get-Date

    #load LabConfig
        . "$PSScriptRoot\LabConfig.ps1"

        if (-not ($LabConfig.Prefix)){
            $labconfig.Prefix="$($PSScriptRoot | Split-Path -Leaf)-"
        }
        if (-not ($LabConfig.SwitchName)){
            $labconfig.SwitchName="LabSwitch"
        }

    #grab all VMs, switches and DC
        $VMs=Get-VM -Name "$($LabConfig.Prefix)*" | Where-Object Name -ne "$($LabConfig.Prefix)DC" -ErrorAction SilentlyContinue | Sort-Object -Property Name
        $vSwitch=Get-VMSwitch "$($labconfig.prefix)$($LabConfig.SwitchName)" -ErrorAction SilentlyContinue
        $extvSwitch=Get-VMSwitch "$($labconfig.prefix)$($LabConfig.SwitchName)-External" -ErrorAction SilentlyContinue
        $DC=Get-VM "$($LabConfig.Prefix)DC" -ErrorAction SilentlyContinue

    #List VMs, Switches and DC
        If ($VMs){
            WriteInfoHighlighted "VMs:"
            $VMS | ForEach-Object {
                WriteInfo "`t $($_.Name)"
            }
        }

        if ($vSwitch){
            WriteInfoHighlighted "vSwitch:"
            WriteInfo "`t $($vSwitch.name)"
        }

        if ($extvSwitch){
            WriteInfoHighlighted "External vSwitch:"
            WriteInfo "`t $($extvSwitch.name)"
        }

        if ($DC){
            WriteInfoHighlighted "DC:"
            WriteInfo "`t $($DC.Name)"
        }

    #just one more space
        WriteInfo ""

    # This is only needed if you kill deployment script in middle when it mounts VHD into mountdir. 
        if ((Get-ChildItem -Path "$PSScriptRoot\temp\mountdir" -ErrorAction SilentlyContinue)){
            Dismount-WindowsImage -Path "$PSScriptRoot\temp\mountdir" -Discard -ErrorAction SilentlyContinue
        }
        if ((Get-ChildItem -Path "$env:Temp\WSLAbMountdir" -ErrorAction SilentlyContinue)){
            Dismount-WindowsImage -Path "$env:Temp\WSLAbMountdir" -Discard -ErrorAction SilentlyContinue
        }

#ask for cleanup and clean all if confirmed.
    if (($extvSwitch) -or ($vSwitch) -or ($VMs) -or ($DC)){
        WriteInfoHighlighted "This script will remove all items listed above. Do you want to remove it?"
        if ((read-host "(type Y or N)") -eq "Y"){
            WriteSuccess "You typed Y .. Cleaning lab"
            if ($DC){
                WriteInfoHighlighted "Removing DC"
                WriteInfo "`t Turning off $($DC.Name)"
                $DC | Stop-VM -TurnOff -Force -WarningAction SilentlyContinue
                WriteInfo "`t Restoring snapshot on $($DC.Name)"
                $DC | Restore-VMsnapshot -Name Initial -Confirm:$False -ErrorAction SilentlyContinue
                Start-Sleep 2
                WriteInfo "`t Removing snapshot from $($DC.Name)"
                $DC | Remove-VMsnapshot -name Initial -Confirm:$False -ErrorAction SilentlyContinue
                WriteInfo "`t Removing DC $($DC.Name)"
                $DC | Remove-VM -Force
            }
            if ($VMs){
                WriteInfoHighlighted "Removing VMs"
                foreach ($VM in $VMs){
                WriteInfo "`t Removing VM $($VM.Name)"
                $VM | Stop-VM -TurnOff -Force -WarningAction SilentlyContinue
                $VM | Remove-VM -Force
                }
            }
            if (($vSwitch)){
                WriteInfoHighlighted "Removing vSwitch"
                WriteInfo "`t Removing vSwitch $($vSwitch.Name)"
                $vSwitch | Remove-VMSwitch -Force
            }
            if (($extvSwitch)){
                WriteInfoHighlighted "Removing vSwitch"
                WriteInfo "`t Removing vSwitch $($extvSwitch.Name)"
                $extvSwitch | Remove-VMSwitch -Force
            }
            #Cleanup folders       
            if ((test-path "$PSScriptRoot\LAB\VMs") -or (test-path "$PSScriptRoot\temp") ){
                WriteInfoHighlighted "Cleaning folders"
                "$PSScriptRoot\LAB\VMs","$PSScriptRoot\temp" | ForEach-Object {
                    if ((test-path -Path $_)){
                        WriteInfo "`t Removing folder $_"
                        remove-item $_ -Confirm:$False -Recurse
                    }    
                }
            }

            #Unzipping configuration files as VM was removed few lines ago-and it deletes vm configuration... 
                $zipfile = "$PSScriptRoot\LAB\DC\Virtual Machines.zip"
                $zipoutput = "$PSScriptRoot\LAB\DC\"
                Microsoft.PowerShell.Archive\Expand-Archive -Path $zipfile -DestinationPath $zipoutput -Force

            # Telemetry
            if((Get-TelemetryLevel) -in $TelemetryEnabledLevels) {
                WriteInfo "Telemetry is set to $(Get-TelemetryLevel) level from $(Get-TelemetryLevelSource)"
                $metrics = @{
                    'script.duration' = ((Get-Date) - $StartDateTime).TotalSeconds
                    'lab.removed.count' = ($VMs | Measure-Object).Count
                }
                Send-TelemetryEvent -Event "Cleanup" -Metrics $metrics -NickName $LabConfig.TelemetryNickName | Out-Null
            }

            #finishing    
                WriteSuccess "Job Done! Press enter to continue ..."
                $exit=Read-Host
        }else {
            WriteErrorAndExit "You did not type Y"
        }
    }else{
        WriteErrorAndExit "No VMs and Switches with prefix $($LabConfig.Prefix) detected. Exitting"
    }
#endregion
