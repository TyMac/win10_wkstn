#
# Cookbook:: win10_wkstn
# Recipe:: default
#
# Copyright:: 2019, Tyler McAdams, All Rights Reserved.

# registry_key 'HKEY_CLASSES_ROOT\*\shell\Open with Notepad\command' do
#   values [{
#     name: '',
#     type: :string,
#     data: 'notepad.exe %1',
#   }]
#   action :create
# end

# registry_key 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\Shell\Bags\1\Desktop' do
#   values [{
#     name: 'Small taskbar buttons',
#     type: :string,
#     data: '1',
#   }]
#   action :create
# end

registry_key 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced' do
  values [{
    name: 'Small taskbar buttons',
    type: :string,
    data: '1',
  }]
  action :create
end

registry_key 'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer' do
  values [{
    name: 'NoDesktop',
    type: :string,
    data: '0',
  }]
  action :create
end

# registry_key 'HKEY_LOCAL_MACHINE\SYSYEM\CurrentControlSet\Services\TCPIP6\Parameters' do
#   values [{
#     name: 'DisabledComponents',
#     type: :string,
#     data: 'FF',
#   }]
#   action :create
# end

registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\AppModelUnlock' do
  values [{
    name: 'AllowDevelopmentWithoutDevLicense',
    type: :string,
    data: '1',
  }]
  action :create
end

registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PreviewBuilds' do
  values [{
    name: 'AllowBuildPreview',
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

registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell\ScriptBlockLogging' do
  values [{
    name: 'EnableScriptBlockLogging',
    type: :dword,
    data: 0
  }]
  action :create
  recursive true
end

# Transcription creates a unique record of every PowerShell session, including all input and output, exactly as it appears in the session.
# Powershell Transcription
registry_key 'HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Microsoft\Windows\PowerShell\Transcription' do
  values [{
    name: 'EnableTranscripting',
    type: :dword,
    data: 0
  }]
  action :create
  recursive true
end

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
    retries 5
    retry_delay 3
    ignore_failure true
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
