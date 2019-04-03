Write-Verbose -Message "Enabling Hyper-V" -Verbose
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
