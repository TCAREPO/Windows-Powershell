# Update Windows 10 to latest Feature 1909
#$dir = 'C:\_Windows_FU\packages'
#mkdir $dir
#$webClient = New-Object System.Net.WebClient
#$url = 'https://go.microsoft.com/fwlink/?LinkID=799445'
#$file = "$($dir)\Win10Upgrade.exe"
#$webClient.DownloadFile($url,$file)
#Start-Process -FilePath $file -ArgumentList '/quietinstall /skipeula /auto upgrade /copylogs $dir'

# Run windows 10 Updates installed Powershell Module
#Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
#Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
#Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers
#Get-WindowsUpdate -install -AcceptAll

#Install Windows 11 from 10, silently.
$dir = 'C:\_Windows_FU\packages'
mkdir $dir
$webClient = New-Object System.Net.WebClient
$url = 'https://go.microsoft.com/fwlink/?linkid=2171764'
$file = "$($dir)\Win11Upgrade.exe"
$webClient.DownloadFile($url,$file)
Start-Process -FilePath $file -ArgumentList '/quietinstall /skipeula /auto upgrade /copylogs $dir'

# Join computer to domain (Restart) examples
#Add-Computer -DomainName paperboys.local -Credential paperboys\tcaadmin -Force -Restart
#Add-Computer -DomainName sawtellrsl -Credential sawtellrsl\tcaadmin -Force -Restart

# Turn Off UAC (User Access Control -Restart Required)
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force

# Run HP Support Assistant - Update support Assistant
# Update HP Software and drivers

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










# Install Applications
# These commands point to your USB directory, which will typically be D drive. If the machine has multiple drives, your USB may no longer be labeled as D drive, and the relevent commands will fail.
# To fix this, simply change the drive letter to the correct one prior to running the commands.

cd D:\TCA_Workstation_Runup\Apps
start .\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Start-Sleep -Seconds 90
winget install -e --id Google.Chrome --silent --accept-source-agreements
winget install --id Adobe.Acrobat.Reader.64-bit --exact --accept-source-agreements --accept-package-agreements --silent
winget install -e --id 7zip.7zip --accept-source-agreements --silent
winget install -e --id VideoLAN.VLC --accept-source-agreements --silent
winget install --id TeamViewer.TeamViewer --accept-source-agreements --silent
start KcsSetup.exe

# Possible winget install command
# If this command works, use this instead of the installer on the runup USB.
Add-AppxPackage https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle

# Possible command to install multiple applications at once
cd D:\TCA_Workstation_Runup\Apps
Add-AppxPackage https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle; start KcsSetup.exe
winget install -e --id Google.Chrome --silent --accept-source-agreements; winget install --id Adobe.Acrobat.Reader.64-bit --exact --accept-source-agreements --accept-package-agreements --silent; winget install --id TeamViewer.TeamViewer --accept-source-agreements --silent; winget install -e --id 7zip.7zip --accept-source-agreements --silent; winget install -e --id VideoLAN.VLC --accept-source-agreements --silent; setup.exe /configure "uninstall.xml"

# Don't install office via winget. 32-bit is currently unsupported via winget, and the 64-bit version which is preinstalled on HP machines needs to be uninstalled before the 32-bit can be installed.
# A work around is to run a preconfigured installer from the USB.
# Put the files from ITGlue (https://tca.au.itglue.com/2448273808656493/documents/folder/3303640252483645/) into the same directory as your agent on your USB.
# Run the following command to uninstall the pre-installed 64-bit version of office.
setup.exe /configure "uninstall.xml"
# Run one of the following commands, depending on which version of office the client uses.
#setup.exe /configure "365business.xml"
#setup.exe /configure "365enterprise.xml"

# Possible chocolatey HP Support assistant install command. Automatically updates to the latest version.
winget install chocolatey
#choco feature enable -n -allowglobalconfirmation
#choco uninstall hpsupportassistant
#choco install hpsupportassistant 
#choco upgrade hpsupportassistant
# uninstall won't work, have to uninstall via the script below.
# choco command doesn't work in powershell ise, only CMD.

# To Uninstall chocolatey, use the command below
#winget uninstall chocolatey


# To Uninstall Windows PC Health Check via powershell
$application = get-wmiobject -class win32_product -filter "name = 'windows pc health check'"
$application.uninstall()
#To view installed applications
#get-wmiobject -class win32_product
#This command could be used to uninstall any remaining HP bloatware after the bloatware removal portion of the script has been run.

# To remove the edge search bar in the desktop, view the following regedit below
# Open Registry Editor (start-run-regedit)
# - Go to Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\
# - Create a new key "Edge"
# - Inside Edge, create a D-WORD "WebWidgetAllowed" and put set its value data to 0"
# I will change this into a powershell script.


# INSTALL HP DRIVERS
#download HPCMSL
#This module will give you commands to download/install HP updates, instead of having to go through HP Support Assistant.
Install-PackageProvider -Name NuGet -Force #make sure Package NuGet is up to date 
Install-Module -Name PowerShellGet  -Force #install the latest version of PowerSHellGet module
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force;
import-module powershellget
set-psrepository -name "psgallery" -installationpolicy trusted 
Install-Module -Name HPCMSL -acceptlicense

#Download HP softpaqs
#Without setting the peramaters, this will download all compatible softpaqs.
#This has what appears to be bugs. For example, it downloaded an nvidia driver package despite the machine not having a GPU
#paramaters exist to select softpaqs by catagory and/or releasetype.
#possible catagories we can exclude: software - security
#the friendlyname parameter makes the file names more readable but may not be consistant.
#downloaded files will have to be installed using seperate commands. The exception to this is get-hpbioswindowsupdate 
#which allows you to download AND install the updated bios with the -flash parameter.
#If softpaq numbers are consistant, these can be easily executed via powershell.
#some files can be able to be install silently in cmd with the /s parameter
#sp 136093, 142308, 142677, 
get-softpaqlist -friendlyname -downloaddirectory c:\softpaqs -download 

#install latest bios
get-hpbioswindowsupdate -severity latest -flash -yes
#If the latest is already installed and this prevents the script from continuing, use the following line instead:
#get-hpbioswindowsupdate -severity latest -flash -yes -force



# REMOVE HP BLOATWARE
#   Remove HP bloatware / crapware
#  
# -- source : https://gist.github.com/mark05e/a79221b4245962a477a49eb281d97388
# -- contrib: francishagyard2, mark05E, erottier, JoachimBerghmans, sikkepitje
# -- ref    : https://community.spiceworks.com/topic/2296941-powershell-script-to-remove-windowsapps-folder?page=1#entry-9032247
# -- note   : this script could use your improvements. contributions welcome!
# -- todo   : Wolf Security improvements ref: https://www.reddit.com/r/SCCM/comments/nru942/hp_wolf_security_how_to_remove_it/

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

# # Uncomment this section to see what is left behind
# Write-Host "Checking stuff after running script"
# Write-Host "For Get-AppxPackage -AllUsers"
# Get-AppxPackage -AllUsers | where {$_.Name -like "*HP*"}
# Write-Host "For Get-AppxProvisionedPackage -Online"
# Get-AppxProvisionedPackage -Online | where {$_.DisplayName -like "*HP*"}
# Write-Host "For Get-Package"
# Get-Package | select Name, FastPackageReference, ProviderName, Summary | Where {$_.Name -like "*HP*"} | Format-List

# # Feature - Ask for reboot after running the script
# $input = Read-Host "Restart computer now [y/n]"
# switch($input){
#           y{Restart-computer -Force -Confirm:$false}
#           n{exit}
#     default{write-warning "Skipping reboot."}
# }
