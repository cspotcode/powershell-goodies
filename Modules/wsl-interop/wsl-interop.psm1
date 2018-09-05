$distro = 'ubuntu'

<#
 # Invoke a command in WSL.  Since Windows sucks at encoding CLI args with spaces or quotes,
 # we take care of encoding and decoding using an ad-hoc mechanism that's easy for bash
 # builtins to parse
 #>
function Invoke-InLinux([Parameter(ValueFromRemainingArguments)][string[]]$argv) {
    & $distro -c "$( ConvertTo-WslPath $PSScriptRoot/command-proxy ) $( ConvertTo-WslInteropEncodedArgs @argv )"
}

$wslPaths = @{ }
<# Get the WSL version of a Windows path, with caching for performance #>
Function ConvertTo-WslPath([string]$path) {
    if(-not $wslPaths.$path) {
        $wslPath = wsl wslpath -a ("$path" -replace '\\','/')
        $wslPaths.$path = $wslPath
        $wslPath
    } else {
        $wslPaths.$path
    }
}

<#
 # Encode argv array into single arg that's easy for bash builtins to decode
 #>
function ConvertTo-WslInteropEncodedArgs([Parameter(ValueFromRemainingArguments)][string[]]$argv) {
  $all = foreach($v in $argv) {
    '\\x' + [System.BitConverter]::tostring([System.Text.Encoding]::Default.GetBytes($v)).Replace('-','\\x')
  }
  ,($all -join ',')
}
