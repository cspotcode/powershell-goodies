#Requires -Edition Core
Function Set-Clipboard {
    param(
        [parameter(ValueFromPipeline)]
        $Text
    )
    write-output $Text | clip.exe
}
Function Get-Clipboard {
    & "$PSScriptRoot/get-windows-clipboard.exe"
}
