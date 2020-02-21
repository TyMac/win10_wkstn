
Import-Module PSWindowsUpdate
Get-WUInstall -WindowsUpdate -AcceptAll -UpdateType Software -AutoReboot
