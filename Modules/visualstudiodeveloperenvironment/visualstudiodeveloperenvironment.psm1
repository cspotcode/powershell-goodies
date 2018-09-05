<#
    Launching Visual Studio's Developer command prompt creates a ton of environment variables and modifies your path.
    However, it's all in cmd.exe.  This Cmdlet grabs all those environment variables and sets them within your PowerShell session.

    "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"
#>
Function Initialize-VisualStudioDeveloperEnvironment {
    $beforeRaw = cmd.exe /C "set"
    $afterRaw = cmd.exe /C '"C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\Common7\Tools\VsDevCmd.bat"&&echo ===DIVIDER===&&set'

    # Parse the output of cmd.exe's `set` into a dictionary
    Function parseEnv($raw) {
        $e = @{}
        $raw | ForEach-Object {
            $g = [regex]::Match($_, '^(.*?)=(.*)$').Captures.Groups
            $e[$g[1].Value] = $g[2].Value
        }
        Return $e
    }

    $before = parseEnv $beforeRaw
    $after = parseEnv ($afterRaw | ForEach-Object { if($found) { Write-Output $_ } elseif($_ -ceq '===DIVIDER===') { $found = $true } })

    # Set all variables that are different in the $after compared to the $before
    ForEach($key in $after.Keys) {
        if($before[$key] -ceq $after[$key]) { continue }
        if($key -eq 'PATH') {
            $beforePaths = $before[$key].Split(';')
            $pathAdditions = $after[$key].Split(';') | Where-Object { -not ($beforePaths -CContains $_) }
            $Env:Path = ($pathAdditions -Join ';') + ';' + $Env:Path
        } else {
            Set-Item -Path "Env:\$key" -Value $after[$key]
        }
    }
}
