#
# Cookbook:: win10_wkstn
# Recipe:: default
#
# Copyright:: 2019, Tyler McAdams, All Rights Reserved.

registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' do
  values [{
    name: 'AllowDevelopmentWithoutDevLicense',
    type: :string,
    data: '1',
  }]
  action :create
end

registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' do
  values [{
    name: 'AppsUseLightTheme',
    type: :string,
    data: '0',
  }]
  action :create
end

registry_key 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' do
  values [{
    name: 'AppsUseLightTheme',
    type: :string,
    data: '0',
  }]
  action :create
end

# reboot 'now' do
#   action :nothing
#   reason 'Cannot continue Chef run without a reboot.'
#   delay_mins 4
# end

# powershell_script 'enable hyper-v' do
#   code 'Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart'
#   notifies :reboot_now, 'reboot[now]', :immediately
# end

powershell_modules = node['win10_wkstn']['ps_modules']

powershell_modules.each do |modules|
  powershell_package modules do
    action :install
  end
end

workstation_apps = node['win10_wkstn']['apps']

workstation_apps.each do |package|
  chocolatey_package package do
    action :install
  end
end

chocolatey_package 'terraform' do
  action :install
end

chocolatey_package 'chefdk' do
  action :install
end

chocolatey_package 'packer' do
  action :install
  version '1.3.4'
end

# powershell_script 'install code extensions' do
#   code <<-EOH
#   $env:Path = "C:\\Program Files\\Microsoft VS Code\\bin"
#   code --install-extension ms-vscode.csharp
#   code --install-extension ms-vscode.powershell
#   code --install-extension Pendrica.chef
#   code --install-extension vscoss.vscode-ansible
#   EOH
# end

powershell_script 'install chef gems' do
  code <<-EOH
  $env:Path = "C:\\opscode\\chefdk\\bin\\"
  chef gem install kitchen-ansible winrm winrm-fs kitchen-pester kitchen-dsc
  EOH
end
