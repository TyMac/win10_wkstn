Write-Verbose -Message "Enabling Hyper-V" -Verbose
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
Add-WindowsFeature Hyper-V-Tools
Add-WindowsFeature Hyper-V-PowerShell
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-Management-PowerShell
