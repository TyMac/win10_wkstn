<#

.SYNOPSIS
This script readies the answer.iso file.

.DESCRIPTION
Generates a secondary ISO for the build process. The Hyperv-ISO Packer builder needs this to load an autounattend.xml file.

.PARAMETER iso_dest
The directory that the answer.iso file shold be outputted.

.PARAMETER files_folder
The folder where all the repo scripts are kept.

.PARAMETER schily_cdrtools_url
The url to download Schily cdrtools.

.PARAMETER proxy_ip
The proxy IP to use.

.PARAMETER packer_iso_dir
The directory that Packer will find / store ISO files.

.PARAMETER packer_version
The version number of the Packer binary to install.

.EXAMPLE
.\mk_answer_iso.ps1 -iso_dest "C:\Users\Public\Documents\Packer_Builds\ISO\" -files_folder .\files -schily_cdrtools_url "https://svwh.dl.sourceforge.net/project/tumagcc/schily-cdrtools-3.02a07.7z" -proxy_ip "192.168.2.1:9090" -packer_iso_dir "C:\Users\Public\Documents\Packer_Builds\ISO\"
Run the command manually. Useful for debugging a build.

.NOTES
The reason for this script is that the Packer Hyper-V builder requires a secondary iso mounted (instead of a floppy) to handle things like presenting the autounattend.xml. 
Any changes to files in this repo (such as autounattend.xml) will require this script to be re-ran before the Packer build is kicked off in order to use those changes.
The Schily cdrtools binary is used in the create_iso function because it is cited directly in Hashicorp's Packer documentation for this specific purpose. 
If you are building behind a proxy, create and set a proxied_environemt variable to true and specify a proxy ip with the -proxy_ip parameter.
The use of Environment]::Exit(1) in the try / catch blocks is required for CI build systems like TeamCity that do not seem to honor normal exit methods.

#>
[CmdletBinding()]
Param (
    [string] $iso_folder,
    [string] $iso_dest,
    [string] $files_folder,
    [string] $schily_cdrtools_url,
    [string] $proxy_ip,
    [string] $packer_iso_dir,
    [string] $packer_version
)

if ($env:proxied_enviornment -eq "true") {
    Write-Verbose -Message "Setting Proxy IP: $proxy_ip" -Verbose
    $env:http_proxy = $proxy_ip
    $env:https_proxy = $proxy_ip
    [net.webrequest]::defaultwebproxy = new-object net.webproxy http://$proxy_ip
    [system.net.webrequest]::defaultwebproxy.BypassProxyOnLocal = $true
} else {
    Write-Verbose -Message "Host IPs not on proxy" -Verbose
}

function create_iso {
    if (Test-Path $iso_folder){
        Remove-Item $iso_folder -Force
    }

    if (Test-Path $files_folder\answer.iso){
        Remove-Item $files_folder\answer.iso -Force
    }

    if (!(Test-Path $packer_iso_dir)){
        New-Item -ItemType Directory -Force -Path $packer_iso_dir
    }

    New-Item -Path $iso_folder -Type Directory -Force

    Copy-Item $files_folder\* $iso_folder\ 

    $textFile = "$iso_folder\autounattend.xml"

    $c = Get-Content -Encoding UTF8 $textFile

    # Enable UEFI and disable Non EUFI
    $c | % { $_ -replace '<!-- Start Non UEFI -->','<!-- Start Non UEFI' } | % { $_ -replace '<!-- Finish Non UEFI -->','Finish Non UEFI -->' } | % { $_ -replace '<!-- Start UEFI compatible','<!-- Start UEFI compatible -->' } | % { $_ -replace 'Finish UEFI compatible -->','<!-- Finish UEFI compatible -->' } | sc -Path $textFile

    &  'C:\Program Files\schily-cdrtools\win32\mkisofs.exe' -r -iso-level 4 -UDF -o $iso_dest $iso_folder

    if (test-path $iso_folder){
        remove-item $iso_folder -Force -Recurse
    }
}

function install_cdrtools {
    if ($env:proxied_enviornment -eq "true") {
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            [net.webrequest]::defaultwebproxy = new-object net.webproxy http://$proxy_ip
            [system.net.webrequest]::defaultwebproxy.BypassProxyOnLocal = $true
            Invoke-WebRequest -Uri $schily_cdrtools_url -proxy "http://$proxy_ip" -OutFile "$files_folder\schily-cdrtools-3.02a07.7z"
        }
        catch [System.Net.WebException] {
            Write-Warning "Could not download schily-cdrtools via proxy. Check your network connectivity."
            $_.Exception.Response
            $error
            [Environment]::Exit(1)
        }
        if ( -not (test-path 'C:\ProgramData\chocolatey')) {
            try {
                [net.webrequest]::defaultwebproxy = new-object net.webproxy "http://$proxy_ip"
                Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
            }
            catch [System.Management.Automation.MethodInvocationException] {
                Write-Warning "Could not install chocolatey via proxy. Check your network connectivity."
                $_.Exception.Response
                [Environment]::Exit(1)
            }
            try {
                choco config set proxy "http://$proxy_ip"
                $pack = choco list --local-only packer | Select-String "packer"
                if (@($pack) -like "packer $packer_version") {
                    Write-Warning "Correct packer version $packer_version installed."
                } else {
                    Write-Warning "Attempting to install packer version $packer_version."
                    if ($pack -gt 0) {
                        Write-Warning "Attempting to remove a previous packer version."
                        choco uninstall packer -y
                        Write-Warning "Attempting to install packer version $packer_version."
                        choco install packer $packer_version -y
                    } else {
                        Write-Warning "Attempting to install packer version $packer_version."
                        choco install packer $packer_version -y
                    }
                }
                choco intall packer --version $packer_version -y
                choco install 7zip.install -y
            }
            catch [System.Management.Automation.CommandNotFoundException] {
                Write-Warning "An exception was found trying to install Choco: $($_.Exception.Message)"
                $_.Exception.Response
                [Environment]::Exit(1)
            }
        } 
        else {
            try {
                choco upgrade 7zip.install -y
            }
            catch [System.Management.Automation.CommandNotFoundException] {
                Write-Warning "An exception was found trying to install Choco: $($_.Exception.Message)"
                $_.Exception.Response
                [Environment]::Exit(1)
            }
        }
        try {
            7z x "$files_folder\schily-cdrtools-3.02a07.7z" -o'C:\Program Files\schily-cdrtools'
        }
        catch [System.Management.Automation.CommandNotFoundException] {
            Write-Warning "An exception was found trying to execute 7zip: $($_.Exception.Message)"
            $_.Exception.Response
            [Environment]::Exit(1)
        }
        catch [System.IO.IOException] {
            Write-Warning "An exception was found trying to execute 7zip: $($_.Exception.Message)"
            $_.Exception.Response
            [Environment]::Exit(1)
        }
        try {
            $oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
            $newpath = "$oldpath;C:\Program Files\schily-cdrtools\win32"
            Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
        } 
        catch [System.Management.Automation.PSArgumentException] {
            "PATH Registry Key Property missing"
        }
        catch [System.Management.Automation.ItemNotFoundException] {
            "PATH Registry Key itself is missing"
        }
    } else {
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            Invoke-WebRequest -Uri $schily_cdrtools_url -OutFile "$files_folder\schily-cdrtools-3.02a07.7z"
        }
        catch [System.Net.WebException] {
            Write-Warning "Could not download schily-cdrtools off proxy. Check your network connectivity."
            $_.Exception.Response
            $error
            [Environment]::Exit(1)
        }
        if ( -not (test-path 'C:\ProgramData\chocolatey')) {
            try {
                Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
            }
            catch [System.Management.Automation.MethodInvocationException] {
                Write-Warning "Could not install chocolatey. Check your network connectivity."
                $_.Exception.Response
                [Environment]::Exit(1)
            }
            try {
                choco install 7zip.install -y
            }
            catch [System.Management.Automation.CommandNotFoundException] {
                Write-Warning "An exception was found trying to install Choco: $($_.Exception.Message)"
                $_.Exception.Response
                [Environment]::Exit(1)
            }
        } 
        else {
            try {
                choco upgrade 7zip.install -y
            }
            catch [System.Management.Automation.CommandNotFoundException] {
                Write-Warning "An exception was found trying to install Choco: $($_.Exception.Message)"
                $_.Exception.Response
                [Environment]::Exit(1)
            }
        }
        try {
            7z x "$files_folder\schily-cdrtools-3.02a07.7z" -o'C:\Program Files\schily-cdrtools'
        }
        catch [System.Management.Automation.CommandNotFoundException] {
            Write-Warning "An exception was found trying to execute 7zip: $($_.Exception.Message)"
            $_.Exception.Response
            [Environment]::Exit(1)
        }
        catch [System.IO.IOException] {
            Write-Warning "An exception was found trying to execute 7zip: $($_.Exception.Message)"
            $_.Exception.Response
            [Environment]::Exit(1)
        }
        try {
            $oldpath = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
            $newpath = "$oldpath;C:\Program Files\schily-cdrtools\win32"
            Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $newPath
        } 
        catch [System.Management.Automation.PSArgumentException] {
            "PATH Registry Key Property missing"
        }
        catch [System.Management.Automation.ItemNotFoundException] {
            "PATH Registry Key itself is missing"
        }
    }
}

if ( -not (test-Path 'C:\Program Files\schily-cdrtools\win32\mkisofs.exe') -or -not (test-Path 'C:\Program Data\chocolatey\bin\mkisofs.exe')) {
    Write-Verbose -Message "Attempting schily-cdrtools installation." -Verbose
    install_cdrtools
    refreshenv
    $env:path += 'C:\Program Files\schily-cdrtools\win32\'
    create_iso
}
else {
    $env:path += 'C:\Program Files\schily-cdrtools\win32\'
    Write-Verbose -Message "Attempting ISO creation." -Verbose
    create_iso
}
