$clockStartTime = $null
$clockStarts = @{}
$bench = $false

Function Enable-BenchmarkClocks {
    ([ref]$bench).value = $true
}
Function Disable-BenchmarkClocks {
    ([ref]$bench).value = $false
}
Function Start-BenchmarkClock($message) {
    if($bench) {
        $clockStarts.$message = get-date
    }
}
Function Stop-BenchmarkClock($message) {
    if($bench) {
        write-host "$message $(((Get-Date) - $clockStarts.$message).toString())"
    }
}
