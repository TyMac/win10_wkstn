$ProgressPreference="SilentlyContinue"
$ErrorActionPreference = "Stop"

for ([byte]$c = [char]'A'; $c -le [char]'Z'; $c++)  
{  
	$variablePath = [char]$c + ':\variables.ps1'

	if (test-path $variablePath) {
		. $variablePath
		break
	}
}

Write-Host "Removing temp folders"
$tempfolders = @("C:\Windows\Temp\*", "C:\Windows\Prefetch\*", "C:\Documents and Settings\*\Local Settings\temp\*", "C:\Users\*\Appdata\Local\Temp\*")
Remove-Item $tempfolders -ErrorAction SilentlyContinue -Force -Recurse

if ($SkipWindowsUpdates){
	Write-Host "Skipping cleanup"
	exit 0
}

Write-Host "Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase"
Dism.exe /online /Cleanup-Image /StartComponentCleanup /ResetBase

exit 0
