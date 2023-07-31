# Rename computer (Restart required)
Rename-Computer -NewName "ComputerName" -Force -Restart

# Turn Off UAC (User Access Control -Restart Required)
New-ItemProperty -Path HKLM:Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -PropertyType DWord -Value 0 -Force

# Turn on Windows feature .Net3.5
enable-windowsoptionalfeature -Online -Featurename netfx3

# turn on Windows feature Telnet client
enable-windowsoptionalfeature -Online -Featurename telnetclient

# Set power option
# powercfg /list
# powercfg /query

# High Performance
#powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Balanced 
#powercfg /setactive 381b4222-f694-41f0-9685-ff5bb260df2e

# Power Saver
#powercfg /setactive a1841308-3541-4fab-bc81-f71556f20b4a

# Turn off screen saver and Lock screen (Power and Sleep, screen turn off never)
powercfg -change -monitor-timeout-ac 10
powercfg -change -standby-timeout-ac 30
powercfg -change -standby-timeout-dc 10
powercfg -change -monitor-timeout-dc 10


c:\windows\system32\diskperf.exe -Y


# Install Applications (change drive letter for USB)
cd 'C:\TCA Workstation Setup'
cmd /c acrordrdc1902120058_en_us.exe -sfx_o"F:\Apps:\" /sALL /msi EULA_ACCEPT=YES
# cmd /c readerdc_uk_xa_install.exe -sfx_o"F:\Apps:\" /sALL /msi EULA_ACCEPT=YES
start KcsSetup.exe
start "Ninite 7Zip Chrome Silverlight VLC Installer.exe"

# Update Windows 10 to latest Feature Update
$dir = 'C:\_Windows_FU\packages'
mkdir $dir
$webClient = New-Object System.Net.WebClient
$url = 'https://go.microsoft.com/fwlink/?LinkID=799445'
$file = "$($dir)\Win10Upgrade.exe"
$webClient.DownloadFile($url,$file)
Start-Process -FilePath $file -ArgumentList '/quietinstall /skipeula /auto upgrade /copylogs $dir'

# Run windows 10 Updates installed Powershell Module
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208 -Force
Install-Module -Name PSWindowsUpdate -Force -Scope AllUsers
Get-WUList

Get-WindowsUpdate -install -AcceptAll -AutoReboot
Get-WindowsUpdate -acc
Get-Help -Name get-windowsupdate 

Get-WUInstall -AcceptAll 


# Join computer to domain (Restart) examples
Add-Computer -DomainName paperboys.local -Credential paperboys\tcaadmin -Force -Restart
Add-Computer -DomainName sawtellrsl -Credential sawtellrsl\tcaadmin -Force -Restart


# Run HP Support Assistant - Update support Assistant
# Update HP Software and drivers


#get windows version
[System.Environment]::OSVersion.Version
Get-ComputerInfo | select WindowsProductName, WindowsVersion, OsHardwareAbstractionLayer

systeminfo /fo csv | ConvertFrom-Csv | select OS*, System*, Hotfix* | Format-List

Start-Process 

start https://get.adobe.com/reader/