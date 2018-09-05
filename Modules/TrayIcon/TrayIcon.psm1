#Requires -PSEdition Desktop
[void][System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

Function New-TrayIcon {
    param(
        $icon = "$PSScriptRoot/powershell.ico",
        $text,
        $module
    )
    # Create hidden form to enable running and closing a GUI event loop
    $form = [System.Windows.Forms.Form]::new()
    $form.Visible = $false
    $form.WindowState = 'minimized'
    $form.ShowInTaskbar = $false
    $form.add_Closing({ $form.ShowInTaskBar = $False }.GetNewClosure())

    # Create tray icon
    $notifyIcon = [System.Windows.Forms.NotifyIcon]::new()
    $notifyIcon.Icon = $icon
    $notifyIcon.Text = $text
    $notifyIcon.Visible = $True
    
    $contextMenu = [System.Windows.Forms.ContextMenu]::new()
    $notifyIcon.ContextMenu = $contextMenu
    
    $r = [pscustomobject]@{
        icon = $notifyIcon;
        form = $form;
        module = $mdule;
    }
    $r | Add-Member -MemberType ScriptMethod -Name 'close' -Value {
        $this.icon.dispose()
        $this.form.close()
    }
    ,$r
}

Function New-TrayMenuItem {
    param(
        [string]$text,
        $action,
        $trayIcon
    )
    if(-not (assertModuleSet $trayIcon)) { return }
    $MenuItem = [System.Windows.Forms.MenuItem]::new()
    $MenuItem.add_Click($trayIcon.module.NewBoundScriptBlock($action))
    $MenuItem.text = $text
    $trayIcon.icon.contextMenu.MenuItems.Add($menuItem)
    ,$MenuItem
}

Function Invoke-TrayIcon {
    param(
        $trayIcon
    )
    if(-not (assertModuleSet $trayIcon)) { return }
    [void][System.Windows.Forms.Application]::Run($trayIcon.form)
}

Function assertModuleSet {
    [Cmdletbinding()]
    param($trayIcon)
    if($trayIcon.module -eq $null) {
        Write-Error "You must set tray icon's 'module' property first.  Recommended method is ```$trayIcon.module = {}.GetNewClosure().module``"
        return $false
    }
    $true
}
