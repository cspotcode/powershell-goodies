# These variables are apparently only available on Linux and Mac versions of PowerShell so we set them manually on Windows.
if($IsWindows -eq $null) {
  $IsWindows = $true
  $IsOSX = $false # should be deprecated
  $IsMacOS = $false
  $IsLinux = $false
  Export-ModuleMember -Variable 'IsWindows', 'IsOSX', 'IsMacOS', 'IsLinux'
}
