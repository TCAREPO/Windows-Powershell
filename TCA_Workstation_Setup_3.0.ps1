# This script will take the source code from 2.5 and build an interactive "flow-based" simple command line interface.

# Each time the script restarts it supplies the corresponding 'Stage' parameter when script is called via scheduled-task
# to ensure that it restarts at the correct point in the script.

# Technician MUST create the first user via OOBE with the username "user".

# D:\Run-up\TCA_Workstation_Setup_3.0.ps1 -start

[CmdletBinding()]
param (
    [Parameter()]
    [Switch]
    $Start,
    [Parameter()]
    [Switch]
    $Stage2
)


# Objects - Storing system info in .txt and objects
$User = 'user'
$ScriptFile = $MyInvocation.MyCommand.Path

# Beginning of run-up process
if($Start){

    # Install dependency modules
    #Set-PSRepository -Name 'PSGallery' -Confirm:$False
    Install-PackageProvider -Name Nuget -Force
    Install-Module PSWindowsUpdate -Force

    # Read start input
    $MachineName = Read-Host 'Enter machine name, excluding the Kaseya group'
    $WindowsVersion = Read-Host 'Enter windows version (write "10" or "11" ONLY)' | Out-File "$PSScriptRoot\Objects.txt"
    Read-Host 'Enter Office 365 edition for installation (Business = 1, Enterprise = 2)' | Out-File "$PSScriptRoot\Objects.txt" -Append

    # Power + windows settings
    # Turn Off UAC (User Access Control -Restart Required)
    New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force

    # Rename machine
    Rename-Computer -NewName $MachineName

    # Turn on Windows feature .Net3.5
    enable-windowsoptionalfeature -Online -Featurename netfx3

    # turn on Windows feature Telnet client
    enable-windowsoptionalfeature -Online -Featurename telnetclient

    # Set power option to Full Power
    powercfg /list
    powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
    powercfg /query

    # Turn off screen saver and Lock screen (Power and Sleep, screen turn off never)
    powercfg -change -monitor-timeout-ac 0
    powercfg -change -standby-timeout-ac 0
    powercfg -change -standby-timeout-dc 0
    powercfg -change -monitor-timeout-dc 0

    # Create scheduled task to continue script after restart
    $Action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "$ScriptFile -Stage2"
    $Trigger = New-ScheduledTaskTrigger -AtLogOn -User $User
    $Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries
    Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName 'OpenScriptAtLogon' -User $User -Settings $Settings -RunLevel Highest
    
    # Check registry keys are not present before modifying them to enable autologon
    $RegKeyAutoAdminLogon = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon'
    $RegKeyDefaultUsername = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultUsername'
    $RegKeyDefaultPassword = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultPassword'
    $RegKeyAutoLogonCount = Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoLogonCount'
    
    if ($RegKeyAutoAdminLogon -ne $Null){
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon'
    }
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon' -Value '1' -PropertyType String
        
    if ($RegKeyDefaultUsername -ne $Null){
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultUsername'
    }
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultUsername' -Value "$User" -PropertyType String
    
    if ($RegKeyDefaultPassword -ne $Null){
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultPassword'
    }
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultPassword' -Value "$User" -PropertyType String
    
    if ($RegKeyAutoLogonCount -ne $Null){
        Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultPassword'
    }
    New-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoLogonCount' -Value '99' -PropertyType DWord
    
    
    Start-Sleep -Seconds 5
    
    # Run windows updates then restart

    Get-WindowsUpdate -AcceptAll
    Restart-Computer
    Write-Output 'Machine will restart and continue run-up process'
    
}

#Install applications
if($Stage2){
    
    # Reset/remove autologon registry keys Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon'
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoAdminLogon'
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultUsername'
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'DefaultPassword'
    Remove-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon' -Name 'AutoLogonCount'
    Unregister-ScheduledTask -TaskName 'OpenScriptAtLogon' -Confirm:$false
    
    # Improved version of default apps
    Add-AppxPackage https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
    winget install -e --id Google.Chrome --silent --accept-source-agreements
    winget install --id Adobe.Acrobat.Reader.64-bit --exact --accept-source-agreements --accept-package-agreements --silent
    winget install -e --id 7zip.7zip --accept-source-agreements --silent
    winget install -e --id VideoLAN.VLC --accept-source-agreements --silent
    winget install -e --id TeamViewer.TeamViewer --accept-source-agreements --silent
    Start-Process $PSScriptRoot\KcsSetup.exe
      
    # Remove shortcuts from desktop
    Remove-Item C:\users\public\desktop\teamviewer.lnk
    Remove-Item C:\users\public\desktop\'Adobe Acrobat.lnk'
    Remove-Item C:\users\public\desktop\'TCO Certified.lnk'
    Remove-Item C:\users\public\desktop\'Microsoft Edge.lnk'
    Remove-Item C:\users\public\desktop\'VLC Media player.lnk'
    Remove-Item C:\users\public\desktop\'HP Support Assistant.lnk'

    # Microsoft 365 installation/uninstall default version
    Start-process "$PSScriptRoot\setup.exe" -Verb RunAs -ArgumentList "/configure $PSScriptRoot\Uninstall.xml"
    Start-Sleep -Seconds 10
    Wait-Process -Name 'conhost' -Timeout 60

    # Install 365 Enterprise 32bit version based on technician selection (Business or Enterprise version)
    $OfficeConfig = (Get-Content -Path $PSScriptRoot\Objects.txt)[1]

    if ($OfficeConfig -eq "1"){
        Start-process "$PSScriptRoot\setup.exe" -Verb RunAs -ArgumentList "/configure $PSScriptRoot\Business.xml"
    }
    if ($OfficeConfig -eq "2"){
        Start-process "$PSScriptRoot\setup.exe" -Verb RunAs -ArgumentList "/configure $PSScriptRoot\Enterprise.xml"
    }
    if (($OfficeConfig -ne 1) -and ($OfficeConfig -ne 2)) {
      #  $Input | Out-file -FilePath ($PSScriptRoot\Objects.txt)[1]       # Work in progress
      Write-Output 'Incorrect input for office apps version'
    }
    
    Wait-Process -Name 'setup' -Timeout 360    
        
# Remove HP bloatware

    # List of built-in apps to remove
    $UninstallPackages = @(
        "AD2F1837.HPJumpStarts"
        "AD2F1837.HPPCHardwareDiagnosticsWindows"
        "AD2F1837.HPPowerManager"
        "AD2F1837.HPPrivacySettings"
        "AD2F1837.HPSureShieldAI"
        "AD2F1837.HPSystemInformation"
        "AD2F1837.HPQuickDrop"
        "AD2F1837.HPWorkWell"
        "AD2F1837.myHP"
        "AD2F1837.HPQuickTouch"
        "AD2F1837.HPEasyClean"
        "AD2F1837.HPSystemInformation"
    )

    # List of programs to uninstall
    $UninstallPrograms = @(
        "HP Client Security Manager"
        "HP Connection Optimizer"
        "HP Documentation"
        "HP MAC Address Manager"
        "HP Notifications"
        "HP Security Update Service"
        "HP System Default Settings"
        "HP Sure Click"
        "HP Sure Click Security Browser"
        "HP Sure Run"
        "HP Sure Recover"
        "HP Sure Sense"
        "HP Sure Sense Installer"
        "HP Wolf Security"
        "HP Wolf Security Application Support for Sure Sense"
        "HP Wolf Security Application Support for Windows"
    )

    $HPidentifier = "AD2F1837"

    $InstalledPackages = Get-AppxPackage -AllUsers `
                | Where-Object {($UninstallPackages -contains $_.Name) -or ($_.Name -match "^$HPidentifier")}

    $ProvisionedPackages = Get-AppxProvisionedPackage -Online `
                | Where-Object {($UninstallPackages -contains $_.DisplayName) -or ($_.DisplayName -match "^$HPidentifier")}

    $InstalledPrograms = Get-Package | Where-Object {$UninstallPrograms -contains $_.Name}

    # Remove appx provisioned packages - AppxProvisionedPackage
    ForEach ($ProvPackage in $ProvisionedPackages) {

        Write-Host -Object "Attempting to remove provisioned package: [$($ProvPackage.DisplayName)]..."

        Try {
            $Null = Remove-AppxProvisionedPackage -PackageName $ProvPackage.PackageName -Online -ErrorAction Stop
            Write-Host -Object "Successfully removed provisioned package: [$($ProvPackage.DisplayName)]"
        }
        Catch {Write-Warning -Message "Failed to remove provisioned package: [$($ProvPackage.DisplayName)]"}
    }

    # Remove appx packages - AppxPackage
    ForEach ($AppxPackage in $InstalledPackages) {
                                                
        Write-Host -Object "Attempting to remove Appx package: [$($AppxPackage.Name)]..."

        Try {
            $Null = Remove-AppxPackage -Package $AppxPackage.PackageFullName -AllUsers -ErrorAction Stop
            Write-Host -Object "Successfully removed Appx package: [$($AppxPackage.Name)]"
        }
        Catch {Write-Warning -Message "Failed to remove Appx package: [$($AppxPackage.Name)]"}
    }

    # Remove installed programs
    $InstalledPrograms | ForEach-Object {

        Write-Host -Object "Attempting to uninstall: [$($_.Name)]..."

        Try {
            $Null = $_ | Uninstall-Package -AllVersions -Force -ErrorAction Stop
            Write-Host -Object "Successfully uninstalled: [$($_.Name)]"
        }
        Catch {Write-Warning -Message "Failed to uninstall: [$($_.Name)]"}
    }

    # Fallback attempt 1 to remove HP Wolf Security using msiexec
    Try {
        MsiExec /x "{0E2E04B0-9EDD-11EB-B38C-10604B96B11E}" /qn /norestart
        Write-Host -Object "Fallback to MSI uninistall for HP Wolf Security initiated"
    }
    Catch {
        Write-Warning -Object "Failed to uninstall HP Wolf Security using MSI - Error message: $($_.Exception.Message)"
    }

    # Fallback attempt 2 to remove HP Wolf Security using msiexec
    Try {
        MsiExec /x "{4DA839F0-72CF-11EC-B247-3863BB3CB5A8}" /qn /norestart
        Write-Host -Object "Fallback to MSI uninistall for HP Wolf 2 Security initiated"
    }
    Catch {
        Write-Warning -Object  "Failed to uninstall HP Wolf Security 2 using MSI - Error message: $($_.Exception.Message)"
    }

    # Uncomment this section to see what is left behind
    Write-Host "Checking stuff after running script"
    Write-Host "For Get-AppxPackage -AllUsers"
    Get-AppxPackage -AllUsers | where {$_.Name -like "*HP*"}
    Write-Host "For Get-AppxProvisionedPackage -Online"
    Get-AppxProvisionedPackage -Online | where {$_.DisplayName -like "*HP*"}
    Write-Host "For Get-Package"
    Get-Package | select Name, FastPackageReference, ProviderName, Summary | Where {$_.Name -like "*HP*"} | Format-List

    # Feature - Ask for reboot after running the script
    #$input = Read-Host "Restart computer now [y/n]"
    #switch($input){
    #        y{Restart-computer -Force -Confirm:$false}
    #        n{exit}
    #    default{write-warning "Skipping reboot."}
    #}


}


