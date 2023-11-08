#setup.exe
#Start-process 'C:\tca\ODT_Test\setup.exe' -Verb RunAs -ArgumentList "/configure C:\tca\ODT_Test\business.xml"
#cmd.exe 'C:\tca\ODT_Test\ODT.bat' -Verb RunAs
Start-process "$PSScriptRoot\setup.exe" -Verb RunAs -ArgumentList "/configure $PSScriptRoot\business.xml"
Read-Host 'Enter Office 365 edition for installation (Business = 1, Enterprise = 2)' | Out-File "$PSScriptRoot\Objects.txt" -Append