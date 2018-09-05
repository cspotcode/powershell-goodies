# Lifted from https://gist.github.com/zippy1981/969855

#Requires -PSEdition Desktop

$ErrorActionPreference = 'Stop'

<#
 # Open a WinForms dialog to preview an image file.
 Press Esc key to close the dialog.
 #>
Function Show-Image {
    param(
        [Parameter(Mandatory = $true)]
        [string]
        $Path
    )
    
    [void][reflection.assembly]::LoadWithPartialName('System.Windows.Forms')

    $file = (Get-Item $Path)

    $img = [System.Drawing.Image]::FromFile($file)

    # This tip from http://stackoverflow.com/questions/3358372/windows-forms-look-different-in-powershell-and-powershell-ise-why/3359274#3359274
    [System.Windows.Forms.Application]::EnableVisualStyles()
    $form = [Windows.Forms.Form]::new()
    $form.Text = 'Image Viewer'
    $form.ClientSize = $img.Size
    #$form.Width = $img.Size.Width
    #$form.Height =  $img.Size.Height
    $pictureBox = [Windows.Forms.PictureBox]::new()
    $pictureBox.Width = $img.Size.Width
    $pictureBox.Height = $img.Size.Height

    $pictureBox.Image = $img
    $form.Controls.Add($pictureBox)
    $form.Add_Shown({
        $form.Activate()
    })
    $form.Add_KeyDown({
        If($_.KeyCode -eq 'Escape') {
            $form.Close()
        }
    })
    $form.ShowDialog()
}
