Start-process notepad.exe
$Process = Get-Process -Name notepad
$Process.WaitForExit()
"Print notepad has closed"