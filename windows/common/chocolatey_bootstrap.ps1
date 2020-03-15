try {
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}
catch [System.Management.Automation.MetadataException] {
    Write-Warning "An exception was caught trying to install Choco: $($_.Exception.Message)"
}
$env:Path = "C:\ProgramData\chocolatey\bin"

choco install chefdk --version 3.7.23 -y
choco install vmware-tools -y
choco install schily-cdrtools -pre -y
choco install chef-client --version 14.7.17 -y
choco install pswindowsupdate -y
