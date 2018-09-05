$icon = New-TrayIcon -text 'My Tray Icon'
$icon.module = {}.getnewclosure().module

New-TrayMenuItem -trayIcon $icon -text 'Notify my phone' -Action {
    Write-Host 'Foo clicked'
    notify 'hello world'
} | out-null
New-TrayMenuItem -trayIcon $icon -text 'Exit' -Action {
    $icon.close()
} | out-null

Invoke-TrayIcon $icon
