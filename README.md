# TLDR - Build Command Example:

`packer build -var iso_url="C:\Users\tyler\Downloads\17763.107.1010
29-1455.rs5_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x64FRE_en-us.iso" -var iso_checksum="0278FC4638741F4A1DC85C3
9ED7FA76BB15FD582165F6EF036E9A9FB2F029351" -var output_directory="C:\Users\tyler\Documents\Virtual Machines\win10" .\win
10_wkstn.json`

## Impetus:

If you develop with Packer you understand the need to build for various platforms. Using this VMware Workstation build, you can nest Hyper-V and VirtualBox inside Windows 10. This allows you to test your Packer features for the most popular Packer builders locally.

* Tested and built with Windows 10 Enterprise. You can download a free trial from Microsoft.
