
[CmdletBinding()]
Param (
    [Parameter()]
    [switch]
    $Boot
)
$ScriptPath = 'C:\tca\GPTRebootPsh.ps1'
$ScriptRestarter = 'C:\tca\ScriptRestarter.ps1'
if ($Boot) {
    Write-Output('Running task')
    Write-Output('Process complete')
    $input = Read-Host('Enter input')
    Write-Output("$input is shitty input")
    Start-Sleep -Seconds 5
    Unregister-ScheduledTask -TaskName "OpenScriptAtLogon" -Confirm:$false
}

else {
# Define the username for the user session
$UserName = "TCA\mathias"

# Create a scheduled task action to open script
$action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-File $ScriptPath -Boot"

# Create a trigger for the task (Run at user logon)
$trigger = New-ScheduledTaskTrigger -AtLogOn -User $UserName

# Disable power conditions
$Settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries

# Register the scheduled task
Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "OpenScriptAtLogon" -User $UserName -Settings $Settings

Write-Output "Scheduled task to run script at user logon has been created for user $UserName."
}


