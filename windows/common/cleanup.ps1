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

chef gem install --no-user-install kitchen-hyperv
New-VMswitch -Name "Packer" -AllowManagementOS $true -NetAdapterName "Ethernet0" # -SwitchType Internal

schtasks /create /tn PackerFwTask /tr "C:\WINDOWS\system32\WindowsPowerShell\v1.0\powershell.exe -File C:\Users\Public\Documents\win_updates.ps1" /SC onstart /NP

exit 0
