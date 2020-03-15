$ProgressPreference = "SilentlyContinue"
$ErrorActionPreference = "Stop"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++) {  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

Write-Verbose -message "Removing temp folders" -verbose
$tempfolders = @("C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "C:\Documents and Settings\*\Local Settings\temp\*", "C:\Users\*\Appdata\Local\Temp\*")
Remove-Item $tempfolders -ErrorAction SilentlyContinue -Force -Recurse

if ($SkipWindowsUpdates) {
	Write-Verbose -message "Skipping cleanup" -verbose
	exit 0
}

Write-Verbose -message "Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase" -verbose
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

# schtasks /create /tn PackerTask /tr "C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -File C:\Users\Public\Documents\win_updates.ps1" /SC onstart /NP

$action = New-ScheduledTaskAction -Execute 'Powershell.exe' -Argument '-NoProfile -command "C:\Users\Public\Documents\win_updates.ps1"'

$trigger =  New-ScheduledTaskTrigger -AtLogOn -User ".\Administrator"

Register-ScheduledTask -Action $action -Trigger $trigger -TaskName "WinUpdates" -Description "Run Windows Updates"

exit 0
