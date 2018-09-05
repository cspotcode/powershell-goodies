<#
.SYNOPSIS
Encode strings of an argv array so that they appear as-is in the process they are passed to.
Prevents args with spaces from being split and quotes and backslashes from disappearing.
#>
Function ConvertTo-EncodedArguments {
  <#
  The rules are strange on Windows.
  See here for a thorough explanation and algorithm:
  https://blogs.msdn.microsoft.com/twistylittlepassagesallalike/2011/04/23/everyone-quotes-command-line-arguments-the-wrong-way/
  
  If -Wrap is specified, arguments are wrapped in double quotes.  In Powershell, normal process invocation wraps arguments in double-quotes automatically, so you should *not* specify -Wrap.  (Doing so would break things)  However, when using Start-Process, it does not wrap in double-quotes, so you *must* specify -Wrap.

  If arg contains any double quotes or whitespace (including vertical tab), it must be wrapped in double quotes and the following escaping must be performed.
  Any double quote must be preceded by a backslash.  Any contiguous sequence of backslashes that immediately preceded either a double quote or the end of the argument
  must all be escaped.  However, backslashes appearing anywhere else must *not* be escaped.
  #>
  param(
    # Accept rest args
    [Parameter(Position=1, ValueFromRemainingArguments = $true)]
    [string[]]
    $Arguments,
    # ... or pipeline values
    [Parameter(ValueFromPipeline = $true)]
    [string[]]
    $PipelineArguments,
    [switch]
    $Wrap
  )
  Begin {
    $wrapper = ''
    if($Wrap) { $wrapper = '"' }
    $encode = {param($v)
      # Will this arg be wrapped by an external process?
      $willBeWrapped = [regex]::IsMatch($v, '\s')
      # Escape double-quotes and preceding backslashes
      $v = $v -Replace '(\\*)"','$1$1\"'
      # If necessary, escape trailing backslashes
      if($willBeWrapped) {
        $v = $v -Replace '(\\+)$','$1$1'
      }
      "$wrapper$v$wrapper"
    }
    # If rest args were provided...
    ForEach($_ in $Arguments) {
      Write-Output (& $encode $_)
    }
  }
  Process {
    # Ignore pipeline if rest args were provided
    if($Arguments -eq $null) {
      Write-Output (& $encode $_)
    }
  }
}
