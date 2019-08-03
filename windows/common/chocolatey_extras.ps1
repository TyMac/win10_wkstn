[CmdletBinding()]
Param (
    [string] $install_azure_agent,
    [string] $agent_dir,
    [string] $agent_token,
    [string] $agent_integration,
    [string] $agent_url,
    [string] $logon_account,
    [string] $logon_passwd
)

if ($install_azure_agent -eq "true") {
    Write-Verbose "Now installing Azure agent." -Verbose
    choco install azure-pipelines-agent --params "'/Directory:$agent_dir /Token:$agent_token /Pool:$agent_integration /Url:$agent_url /LogonAccount:$logon_account /LogonPassword:$logon_passwd'" -y
} else {
    Write-Verbose "Azure agent install skipped." -Verbose
}
