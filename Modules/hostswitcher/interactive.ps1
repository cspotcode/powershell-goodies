import-module $PSScriptRoot/hostswitcher.psm1
# InteractiveHostGroupToggle

# If not running as admin, launch self as admin
$isAdmin = (
    [Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if(!$isAdmin) {
    # Launch this script as admin in a new window; exit self
    start-process -verb runAs -FilePath powershell -ArgumentList @('-noexit','-nologo','-noprofile','-file',$myinvocation.mycommand.definition)
    $Host.SetShouldExit(0)
    exit
}

set-location "$home/.hostswitcher"
function prompt { "HOSTS>" }

set-alias enable enable-hostgroup
set-alias disable disable-hostgroup
set-alias list get-hostgroups

function edit {
    & notepad C:\windows\System32\drivers\etc\hosts
}

$PSModuleAutoloadingPreference = 'None'

$Host.UI.RawUI.WindowTitle = 'Hosts Editor'

Write-Host @"
Commands
========
list
enable
disable
edit

All Host Groups
===============
"@

list
