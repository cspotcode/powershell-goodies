function Open-Explorer {
    [CmdletBinding()]
    param($path = '.')
    
    if($IsWindows -ne $false) {
        explorer $path
    } elseif($IsMacOS) {
        # Technically this is a lazy hack since `open` can open more than directories
        open $path
    }
}
