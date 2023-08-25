# This script will take the source code from 2.5 and build an interactive "flow-based" simple command line interface
# IMPORTANT: RUN-UP USB MUST BE THE ONLY EXTERNAL DRIVE CONNECTED!

# Objects
$RunUpDrive = ((Get-Disk | Where-Object -FilterScript {$_.Bustype -Eq "USB"}) | Get-Partition).DriveLetter # Finds the USB drive and captures drive letter within $RunUpDrive
$AppsPath = "$RunUpDrive\TCA_Workstation_Runup\Apps" # Creates a string for the default apps file path



# Power + windows settings
# Turn Off UAC (User Access Control -Restart Required)
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force

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






#Install applications

# These commands point to your USB directory, which will typically be D drive.
Set-Location -Path $AppsPath
Start-Process .\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
Start-Sleep -Seconds 90
winget install -e --id Google.Chrome --silent --accept-source-agreements
winget install --id Adobe.Acrobat.Reader.64-bit --exact --accept-source-agreements --accept-package-agreements --silent
winget install -e --id 7zip.7zip --accept-source-agreements --silent
winget install -e --id VideoLAN.VLC --accept-source-agreements --silent
winget install -e --id TeamViewer.TeamViewer --accept-source-agreements --silent
Start-Process KcsSetup.exe




