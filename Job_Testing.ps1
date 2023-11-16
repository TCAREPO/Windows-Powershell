Start-process notepad.exe
$Process = Get-Process -Name notepad
Wait-Process -name notepad
$Process.WaitForExit()
"Print notepad has closed"

46460bd9-054c-446b-8992-bb8ca6acc241

install-Module AzureADPreview -AllowClobber
import-Module azureadpreview
Connect-AzureAD
install-module
ConvertStaticGroupToDynamic "46460bd9-054c-446b-8992-bb8ca6acc241"