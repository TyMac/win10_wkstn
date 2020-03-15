Write-Verbose -message "Installing Kitchen-hyperv chef gems" -verbose
chef gem install --no-user-install kitchen-hyperv

Write-Verbose -message "Configuring Hyper-V vSwitch" -verbose
New-VMswitch -Name "Packer" -AllowManagementOS $true -NetAdapterName "Ethernet0" # -SwitchType Internal
