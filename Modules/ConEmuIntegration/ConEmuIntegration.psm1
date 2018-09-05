<# ConEmuIntegration

Usage:
Load in your PowerShell profile.
Configure ConEmu to set the environment variable `IS_CON_EMU` to `true`.
NOTE: This module will immediately *unset* that environment variable.
If you want to detect conemu yourself, use the `Test-IsConEmu` function or the `$IsConEmu` variable.
#>


#Requires -Modules Encode-Arguments

Function Set-ConEmuDirFallback($path) {
  ([Ref]$conEmuDirFallback).Value = $path
  ([Ref]$ConEmuPath).Value = Get-ConEmuDir
}

Function Test-IsConEmu {
  return $IsConEmu
}

Function Get-ConEmuDir {
    if($IsConEmu) {
        $env:ConEmuDir
    } else {
        $conEmuDirFallback
    }
}

<#
.SYNOPSIS
Attaches a console window to ConEmu so that it appears as a ConEmu tab.
#>
Function Add-ConsoleToConEmu {
  & (Get-BinClientPath) /ATTACH /NOCMD
}

Function New-Tab([string]$task = 'powershell', [string]$Pwd) {
  if($PSBoundParameters.keys -contains 'Pwd') {
    & (Get-BinPath) -Single -Dir $Pwd -Run "{$task}"
  } else {
    & (Get-BinPath) -Single -Here -Run "{$task}"
  }
}

Function Set-TabTitle($title) {
  & (Get-BinClientPath) -GuiMacro Rename 0 (ConvertTo-EncodedArguments $title) | Out-Null
}

Enum TermMode {
  XTerm = 1
  Windows = 0
}

Function Set-TermMode {
  Param(
    [Parameter(Mandatory = $true)]
    [TermMode]$Mode
  )
  & (Get-BinClientPath) -GuiMacro TermMode 0 $Mode | Out-Null
}


Function Set-Cwd {
  if(Test-LocationIsFilesystem) {
    $bin = Get-BinClientPath
    New-MadThread -ScriptBlockUnique {param($PWD, $bin)
      set-location $PWD
      & $bin -StoreCwd
    } -UseEmbeddedParameters | out-null
  }
}


Function Test-LocationIsFilesystem {
  (Get-Location).Provider.Name -eq "FileSystem"
}

Function Get-BinClientPath {
  return "$(Get-ConEmuDir)/ConEmu/ConEmuC$( _64BitBinSuffix ).exe"
}
Function Get-BinPath {
  return "$(Get-ConEmuDir)/ConEmu$( _64BitBinSuffix ).exe"
}
Function _64BitBinSuffix {
  If(_is64Bit) { '64' } else { '' }
}
Function _is64Bit {
  return [Environment]::Is64BitProcess
}

# True if this console is running within ConEmu
$IsConEmu = $false
# Location of conemu binaries if location can't be detected from environment variables
$conEmuDirFallback = $null
# PROBABLY DEPRECATED SOON
$ConEmuPath = $null
if($env:IS_CON_EMU) {
  $env:IS_CON_EMU = $null
  $IsConEmu = $true
  $ConEmuPath = Get-ConEmuDir
}
