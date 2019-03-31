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

# powershell_script 'enable hyper-v' do
#   code 'Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart'
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

powershell_script 'install code extensions' do
  code <<-EOH
  code --install-extension ms-vscode.csharp
  code --install-extension ms-vscode.powershell
  code --install-extension Pendrica.chef
  code --install-extension vscoss.vscode-ansible
  EOH
end

powershell_script 'install chef gems' do
  code <<-EOH
  $env:Path = "C:\\opscode\\chefdk\\bin\\"
  chef gem install kitchen-ansible winrm winrm-rm kitchen-pester kitchen-dsc
  EOH
end