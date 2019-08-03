# TLDR - Build Command Example:

`packer build -var iso_url='/Users/tmcadams/Downloads/17763.107.101029-1455.rs5_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso' -var iso_checksum='0278FC4638741F4A1DC85C39ED7FA76BB15FD582165F6EF036E9A9FB2F029351' -var output_directory='/Users/tmcadams/win10' -var iso_folder='C:\Users\Public\Documents\answer-iso' -var iso_dest='C:\Users\Public\Documents\Packer_Builds\ISO\answer.iso' -var files_folder='C:\Users\Public\Documents\files' -var schily_cdrtools_url='https://svwh.dl.sourceforge.net/project/tumagcc/schily-cdrtools-3.02a07.7z' -var proxy_ip='192.168.5.1:9090' -var packer_iso_dir='C:\Users\Public\Documents\Packer_Builds\ISO\' -var packer_version='1.3.4' ./win10_wkstn.json`

## Impetus:

If you develop with Packer you understand the need to build for various platforms. Using this VMware Workstation build, you can nest Hyper-V and VirtualBox inside Windows 10. This allows you to test your Packer features for the most popular Packer builders locally. I include a powershell script to generate an answer iso required for using Packer with gen 2 Hyper-V VMs. The script validates itself during the build by creating a mock anser.iso.

[![Build status](https://tymac.visualstudio.com/win10_wkstn/_apis/build/status/win10_wkstn-CI)](https://tymac.visualstudio.com/win10_wkstn/_build/latest?definitionId=-1)

* This packer image can be built using a build 17763.rc5 Windows 10 Enterprise iso on OS X and Windows 10 Pro workstations.
* It has been tested using VMware Fusion 11.1.0 and VMware Workstation 15 Pro with Packer 1.4.1 and chef-client 14.7.17.
* You can download a free trial iso of Windows 10 Enterprise from Microsoft.

## The build does various things at different stages:
1. At first boot during the Windows installation the autounattend installs / configures:
    * Chocolatey
    * chef-client
    * VMware Tools
    * Configures WinRM for PowerShell remoting
    * Installs the AzureRM PowerShell module
    * Enables the Hyper-V Windows Feature and assocated management tools
2. During Packer provisioning a PowerShell provisioner installs / configures:
    * A PowerShell script (mk_answer_iso.ps1) that will allow you to create answer ISOs for Hyper-V Gen 2 VM testing
    * With the install_azure_agent var set to true, a powershell script will install the azure-devops-agent with chocolatey
3. During Packer provisioning a chef-solo provisioner installs / configures:
    * Various registry tweaks for usability, security, debugging and development
    * Several PowerShell modules for Packer development
    * Several Chocolatey installed programs for development and usability
4. Finally, a Packer provisioning a PowerShell provisioner:
    * cleans up the image for usage
    * configures WinRM for future ansible configuration
