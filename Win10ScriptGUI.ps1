Function QuickPrivilegesElevation {
    # Used from https://stackoverflow.com/a/31602095 because it preserves the working directory!
    If (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }
}

Function LoadLibs {

    Write-Host "Your Current Folder $pwd"
    Write-Host "Script Current Folder $PSScriptRoot"
    Write-Host ""
    Push-Location "$PSScriptRoot"
	
    Push-Location -Path "lib\"
    Get-ChildItem -Recurse *.ps*1 | Unblock-File

    #Import-Module -DisableNameChecking .\"check-os-info.psm1"      # Not Used
    Import-Module -DisableNameChecking .\"count-n-seconds.psm1"
    Import-Module -DisableNameChecking .\"set-script-policy.psm1"
    Import-Module -DisableNameChecking .\"setup-console-style.psm1" # Make the Console look how i want
    Import-Module -DisableNameChecking .\"simple-message-box.psm1"
    Import-Module -DisableNameChecking .\"title-templates.psm1"
    Pop-Location

}

Function PromptPcRestart {

    $Ask = "If you want to see the changes restart your computer!
    Do you want to Restart now?"
    
    switch (ShowQuestion -Title "Read carefully" -Message $Ask) {
        'Yes' {
            Write-Host "You choose Yes."
            Restart-Computer        
        }
        'No' {
            Write-Host "You choose to Restart later"
            Write-Host "You choose No. (No = Cancel)"
        }
        'Cancel' {
            # With Yes, No and Cancel, the user can press Esc to exit
            Write-Host "You choose to Restart later"
            Write-Host "You choose Cancel. (Cancel = No)"
        }
    }
    
}

# https://docs.microsoft.com/pt-br/powershell/scripting/samples/creating-a-custom-input-box?view=powershell-7.1
# Adapted majorly from https://github.com/ChrisTitusTech/win10script and https://github.com/Sycnex/Windows10Debloater
Function PrepareGUI {

    # Loading System Libs
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # <=== AFTER PROCESS ===>

    $Global:NeedRestart = $false
    $DoneTitle = "Done"
    $DoneMessage = "Proccess Completed!"

    # <=== SIZES LAYOUT ===>

    # To Forms
    $MaxWidth = 854
    $MaxHeight = 480
    # To Panels
    $CurrentPanelIndex = -2
    $NumOfPanels = 3
    [int]$PanelWidth = ($MaxWidth / $NumOfPanels) # 284
    # To Labels
    $LabelWidth = 25
    $LabelHeight = 10
    # To Buttons
    $ButtonWidth = 150
    $ButtonHeight = 30
    $BigButtonHeight = 70
    # To Fonts
    $DocumentTitle2 = 16
    $DocumentTitle3 = 14
    $DocumentTitle4 = 12

    # <=== FONTS ===>
    
    $Fonts = @(
        "Arial", # 0
        "Bahnschrift", # 1
        "Calibri", # 2
        "Cambria", # 3
        "Cambria Math", # 4
        "Candara", # 5
        "Comic Sans MS", # 6
        "Consolas", # 7
        "Constantia", # 8
        "Corbel", # 9
        "Courier New", # 10
        "Ebrima", # 11
        "Franklin Gothic", # 12
        "Gabriola", # 13
        "Gadugi", # 14
        "Georgia", # 15
        "HoloLens MDL2 Assets", # 16
        "Impact", # 17
        "Ink Free", # 18
        "Javanese Text", # 19
        "Leelawadee UI", # 20
        "Lucida Console", # 21
        "Lucida Sans Unicode", # 22
        "Malgun Gothic", # 23
        "Microsoft Himalaya", # 24
        "Microsoft JhengHei", # 25
        "Microsoft JhengHei UI", # 26
        "Microsoft New Tai Lue", # 27
        "Microsoft PhagsPa", # 28
        "Microsoft Sans Serif", # 29
        "Microsoft Tai Le", # 30
        "Microsoft YaHei", # 31
        "Microsoft YaHei UI", # 32
        "Microsoft Yi Baiti", # 33
        "MingLiU_HKSCS-ExtB", # 34
        "MingLiU-ExtB", # 35
        "Mongolian Baiti", # 36
        "MS Gothic", # 37
        "MS PGothic", # 38
        "MS UI Gothic", # 39
        "MV Boli", # 40
        "Myanmar Text", # 41
        "Nirmala UI", # 42
        "NSimSun", # 43
        "Palatino Linotype", # 44
        "PMingLiU-ExtB", # 45
        "Segoe Fluent Icons", # 46
        "Segoe MDL2 Assets", # 47
        "Segoe Print", # 48
        "Segoe Script", # 49
        "Segoe UI", # 50
        "Segoe UI Emoji", # 51
        "Segoe UI Historic", # 52
        "Segoe UI Symbol", # 53
        "Segoe UI Variable", # 54
        "SimSun", # 55
        "SimSun-ExtB", # 56
        "Sitka Text", # 57
        "Sylfaen", # 58
        "Symbol", # 59
        "Tahoma", # 60
        "Times New Roman", # 61
        "Trebuchet MS", # 62
        "Verdana", # 63
        "Webdings", # 64
        "Wingdings", # 65
        "Yu Gothic", # 66
        "Yu Gothic UI", # 67
        "Unispace", # 68
        # Installable               # ##
        "Courier", # 69
        "Fixedsys", # 70
        "JetBrains Mono", # 71
        "JetBrains Mono NL", # 72
        "Modern", # 73
        "MS Sans Serif", # 74
        "MS Serif", # 75
        "Roman", # 76
        "Script", # 77
        "Small Fonts", # 78
        "System", # 79
        "Terminal"                  # 80
    )

    # <=== LOCATIONS LAYOUT ===>

    [int]$TitleLabelX = $PanelWidth * 0.15
    [int]$TitleLabelY = $MaxHeight * 0.01
    [int]$CaptionLabelX = $PanelWidth * 0.25
    [int]$ButtonX = $PanelWidth * 0.15

    # <=== COLOR PALETTE ===>

    $Green = "#1fff00"
    $LightBlue = "#00ffff"
    $LightGray = "#eeeeee"
    $WinDark = "#252525"

    # <=== GUI ELEMENT LAYOUT ===>

    # Panel Layout

    $CurrentPanelIndex++ # -1
    $PWidth = $PanelWidth
    $PHeight = $MaxHeight

    # Title Label Layout

    $TLAutoSize = $true
    $TLWidth = $LabelWidth
    $TLHeight = $LabelHeight
    $TLLocation = New-Object System.Drawing.Point($TitleLabelX, $TitleLabelY)
    $TLFont = New-Object System.Drawing.Font($Fonts[62], $DocumentTitle2, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $TLForeColor = [System.Drawing.ColorTranslator]::FromHtml("$Green")

    # Caption Label Layout

    $CLAutoSize = $true
    $CLWidth = $LabelWidth
    $CLHeight = $LabelHeight
    $CLFont = New-Object System.Drawing.Font($Fonts[62], $DocumentTitle3)
    $CLForeColor = [System.Drawing.ColorTranslator]::FromHtml("$Green")

    # Big Button Layout

    $BBWidth = $ButtonWidth
    $BBHeight = $BigButtonHeight
    $BBLocation = New-Object System.Drawing.Point($ButtonX, 40)
    $BBFont = New-Object System.Drawing.Font($Fonts[62], $DocumentTitle4, [System.Drawing.FontStyle]([System.Drawing.FontStyle]::Bold))
    $BBForeColor = [System.Drawing.ColorTranslator]::FromHtml("$LightBlue")

    # Small Button Layout

    $SBWidth = $ButtonWidth
    $SBHeight = $ButtonHeight
    $SBFont = New-Object System.Drawing.Font($Fonts[62], $DocumentTitle4)
    $SBForeColor = [System.Drawing.ColorTranslator]::FromHtml("$LightGray")

    # <=== DISPLAYED GUI ===>

    # Main Window:
    $Form = New-Object System.Windows.Forms.Form
    $Form.BackColor = [System.Drawing.ColorTranslator]::FromHtml("$WinDark")
    $Form.FormBorderStyle = 'FixedSingle'   # Not adjustable
    $Form.MinimizeBox = $true               # Remove the Minimize Button
    $Form.MaximizeBox = $false              # Remove the Maximize Button
    $Form.Size = New-Object System.Drawing.Size($MaxWidth, $MaxHeight)
    $Form.StartPosition = 'CenterScreen'    # Appears on the center
    $Form.Text = "Windows 10 Smart Debloat - by LeDragoX"
    $Form.TopMost = $false

    # Icon: https://stackoverflow.com/a/53377253
    $iconBase64 = [Convert]::ToBase64String((Get-Content ".\lib\images\windows-11-logo.png" -Encoding Byte))
    $iconBytes = [Convert]::FromBase64String($iconBase64)
    $stream = New-Object IO.MemoryStream($iconBytes, 0, $iconBytes.Length)
    $stream.Write($iconBytes, 0, $iconBytes.Length);
    $Form.Icon = [System.Drawing.Icon]::FromHandle((New-Object System.Drawing.Bitmap -Argument $stream).GetHIcon())
    
    # Panel 1 to put Labels and Buttons
    $CurrentPanelIndex++    # 0
    $Panel1 = New-Object system.Windows.Forms.Panel
    $Panel1.width = $PWidth
    $Panel1.height = $PHeight
    $Panel1.location = New-Object System.Drawing.Point(($PWidth * $CurrentPanelIndex), 0)
    
    # Panel 2 to put Labels and Buttons
    $CurrentPanelIndex++
    $Panel2 = New-Object system.Windows.Forms.Panel
    $Panel2.width = $PWidth
    $Panel2.height = $PHeight
    $Panel2.location = New-Object System.Drawing.Point(($PWidth * $CurrentPanelIndex), 0)

    # Panel 3 to put Labels and Buttons
    $CurrentPanelIndex++
    $Panel3 = New-Object system.Windows.Forms.Panel
    $Panel3.width = $PanelWidth
    $Panel3.height = $MaxHeight - [int]($MaxHeight * 0.5)
    $Panel3.location = New-Object System.Drawing.Point(($PWidth * $CurrentPanelIndex), 0)

    # Panel 1 ~> Title Label 1
    $TitleLabel1 = New-Object system.Windows.Forms.Label
    $TitleLabel1.text = "System Tweaks"
    $TitleLabel1.AutoSize = $TLAutoSize
    $TitleLabel1.width = $TLWidth
    $TitleLabel1.height = $TLHeight
    $TitleLabel1.location = $TLLocation
    $TitleLabel1.Font = $TLFont
    $TitleLabel1.ForeColor = $TLForeColor
    $Panel1.Controls.Add($TitleLabel1)

    # Panel 2 ~> Title Label 2
    $TitleLabel2 = New-Object system.Windows.Forms.Label
    $TitleLabel2.text = "Misc. Tweaks"
    $TitleLabel2.AutoSize = $TLAutoSize
    $TitleLabel2.width = $TLWidth
    $TitleLabel2.height = $TLHeight
    $TitleLabel2.location = $TLLocation
    $TitleLabel2.Font = $TLFont
    $TitleLabel2.ForeColor = $TLForeColor
    $Panel2.Controls.Add($TitleLabel2)

    # Panel 3 ~> Title Label 3
    $TitleLabel3 = New-Object system.Windows.Forms.Label
    $TitleLabel3.text = "Software Install"
    $TitleLabel3.AutoSize = $TLAutoSize
    $TitleLabel3.width = $TLWidth
    $TitleLabel3.height = $TLHeight
    $TitleLabel3.location = $TLLocation
    $TitleLabel3.Font = $TLFont
    $TitleLabel3.ForeColor = $TLForeColor
    $Panel3.Controls.Add($TitleLabel3)

    # Panel 2 ~> Caption Label 1
    $CaptionLabel1 = New-Object system.Windows.Forms.Label
    $CaptionLabel1.text = "- Theme -"
    $CaptionLabel1.location = New-Object System.Drawing.Point($CaptionLabelX, 35)
    $CaptionLabel1.AutoSize = $CLAutoSize
    $CaptionLabel1.width = $CLWidth
    $CaptionLabel1.height = $CLHeight
    $CaptionLabel1.Font = $CLFont
    $CaptionLabel1.ForeColor = $CLForeColor
    $Panel2.Controls.Add($CaptionLabel1)

    # Panel 2 ~> Caption Label 2
    $CaptionLabel2 = New-Object system.Windows.Forms.Label
    $CaptionLabel2.text = "- Cortana -"
    $CaptionLabel2.location = New-Object System.Drawing.Point($CaptionLabelX, 135)
    $CaptionLabel2.AutoSize = $CLAutoSize
    $CaptionLabel2.width = $CLWidth
    $CaptionLabel2.height = $CLHeight
    $CaptionLabel2.Font = $CLFont
    $CaptionLabel2.ForeColor = $CLForeColor
    $Panel2.Controls.Add($CaptionLabel2)
    
    # Panel 1 ~> Button 1 (Big)
    $ApplyTweaks = New-Object system.Windows.Forms.Button
    $ApplyTweaks.text = "Apply Tweaks"
    $ApplyTweaks.width = $BBWidth
    $ApplyTweaks.height = $BBHeight
    $ApplyTweaks.location = $BBLocation
    $ApplyTweaks.Font = $BBFont
    $ApplyTweaks.ForeColor = $BBForeColor
    $Panel1.Controls.Add($ApplyTweaks)
    
    # Panel 1 ~> Button 2
    $uiTweaks = New-Object system.Windows.Forms.Button
    $uiTweaks.text = "UI/UX Tweaks"
    $uiTweaks.location = New-Object System.Drawing.Point($ButtonX, 125)
    $uiTweaks.width = $SBWidth
    $uiTweaks.height = $SBHeight
    $uiTweaks.Font = $SBFont
    $uiTweaks.ForeColor = $SBForeColor
    $Panel1.Controls.Add($uiTweaks)

    # Panel 1 ~> Button 3
    $RepairWindows = New-Object system.Windows.Forms.Button
    $RepairWindows.text = "Repair Windows"
    $RepairWindows.location = New-Object System.Drawing.Point($ButtonX, 160)
    $RepairWindows.width = $SBWidth
    $RepairWindows.height = $SBHeight
    $RepairWindows.Font = $SBFont
    $RepairWindows.ForeColor = $SBForeColor
    $Panel1.Controls.Add($RepairWindows)    

    # Panel 2 ~> Button 1
    $DarkMode = New-Object system.Windows.Forms.Button
    $DarkMode.text = "Dark Mode"
    $DarkMode.location = New-Object System.Drawing.Point($ButtonX, 65)
    $DarkMode.width = $SBWidth
    $DarkMode.height = $SBHeight
    $DarkMode.Font = $SBFont
    $DarkMode.ForeColor = $SBForeColor
    $Panel2.Controls.Add($DarkMode)
    
    # Panel 2 ~> Button 2
    $LightMode = New-Object system.Windows.Forms.Button
    $LightMode.text = "Light Mode"
    $LightMode.location = New-Object System.Drawing.Point($ButtonX, 100)
    $LightMode.width = $SBWidth
    $LightMode.height = $SBHeight
    $LightMode.Font = $SBFont
    $LightMode.ForeColor = $SBForeColor
    $Panel2.Controls.Add($LightMode)

    # Panel 2 ~> Button 3
    $EnableCortana = New-Object system.Windows.Forms.Button
    $EnableCortana.text = "Enable"
    $EnableCortana.location = New-Object System.Drawing.Point($ButtonX, 165)
    $EnableCortana.width = $SBWidth
    $EnableCortana.height = $SBHeight
    $EnableCortana.Font = $SBFont
    $EnableCortana.ForeColor = $SBForeColor
    $Panel2.Controls.Add($EnableCortana)

    # Panel 2 ~> Button 4
    $DisableCortana = New-Object system.Windows.Forms.Button
    $DisableCortana.text = "Disable"
    $DisableCortana.location = New-Object System.Drawing.Point($ButtonX, 200)
    $DisableCortana.width = $SBWidth
    $DisableCortana.height = $SBHeight
    $DisableCortana.Font = $SBFont
    $DisableCortana.ForeColor = $SBForeColor
    $Panel2.Controls.Add($DisableCortana)
    
    # Panel 3 ~> Button 1 (Big)
    $PkgSwInstaller = New-Object system.Windows.Forms.Button
    $PkgSwInstaller.text = "Install Basic Programs (Chocolatey)"
    $PkgSwInstaller.width = $BBWidth
    $PkgSwInstaller.height = $BBHeight
    $PkgSwInstaller.location = $BBLocation
    $PkgSwInstaller.Font = $BBFont
    $PkgSwInstaller.ForeColor = $BBForeColor
    $Panel3.Controls.Add($PkgSwInstaller)
    
    # Image Logo from the Script
    $PictureBox1 = New-Object system.Windows.Forms.PictureBox
    $PictureBox1.width = 150
    $PictureBox1.height = 150
    $PictureBox1.location = New-Object System.Drawing.Point(($MaxWidth * 0.72), ($MaxHeight * 0.5))
    $PictureBox1.imageLocation = ".\lib\images\script-logo.png"
    $PictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::Zoom

    # <=== CLICK EVENTS ===>

    # Panel 1 ~> Button 1 Mouse Click listener
    $ApplyTweaks.Add_Click( {

            Push-Location -Path "scripts\"
            Clear-Host
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
            $PictureBox1.imageLocation = ".\lib\images\script-logo2.png"
            $PictureBox1.SizeMode = [System.Windows.Forms.PictureBoxSizeMode]::StretchImage
            $Form.Update()
                
            $Scripts = @(
                # [Recommended order] List of Scripts
                "backup-system.ps1"
                "silent-debloat-softwares.ps1"
                "optimize-scheduled-tasks.ps1"
                "optimize-services.ps1"
                "remove-bloatware-apps.ps1"
                "optimize-privacy-and-performance.ps1"
                "personal-optimizations.ps1"
                "optimize-security.ps1"
                "enable-optional-features.ps1"
                "remove-onedrive.ps1"
            )
        
            ForEach ($FileName in $Scripts) {
                Title2Counter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName"
                #pause ### FOR DEBUGGING PURPOSES
            }
            Pop-Location

            $Global:NeedRestart = $true
            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
        })    

    # Panel 1 ~> Button 2 Mouse Click listener
    $uiTweaks.Add_Click( {

            Push-Location -Path "scripts\"
            Clear-Host
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
            $Scripts = @(
                # [Recommended order] List of Scripts
                "manual-debloat-softwares.ps1"
            )
        
            ForEach ($FileName in $Scripts) {
                Title2Counter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName"
                #pause ### FOR DEBUGGING PURPOSES
            }
            Pop-Location

            $Global:NeedRestart = $true
            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
        })

    # Panel 1 ~> Button 3 Mouse Click listener
    $RepairWindows.Add_Click( {

            Push-Location -Path "scripts\"
            Clear-Host
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
            $Scripts = @(
                # [Recommended order] List of Scripts
                "backup-system.ps1"
                "repair-windows.ps1"
            )
        
            ForEach ($FileName in $Scripts) {
                Title2Counter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName"
                #pause ### FOR DEBUGGING PURPOSES
            }
            Pop-Location
        
            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
        })

    # Panel 2 ~> Button 1 Mouse Click listener
    $DarkMode.Add_Click( {

            Push-Location "utils\"
            Write-Host "[+] Enabling Dark theme..."
            regedit /s dark-theme.reg
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
        })

    # Panel 2 ~> Button 2 Mouse Click listener
    $LightMode.Add_Click( {

            Push-Location "utils\"
            Write-Host "[+] Enabling Light theme..."
            regedit /s light-theme.reg
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
        })

    # Panel 2 ~> Button 3 Mouse Click listener
    $EnableCortana.Add_Click( {

            Push-Location "utils\"
            Write-Host "[+] Enabling Cortana..."
            regedit /s enable-cortana.reg
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
        })
    
    # Panel 2 ~> Button 4 Mouse Click listener
    $DisableCortana.Add_Click( {

            Push-Location "utils\"
            Write-Host "[-] Disabling Cortana..."
            regedit /s disable-cortana.reg
            Pop-Location

            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
        })

    # Panel 3 ~> Button 1 Mouse Click listener
    $PkgSwInstaller.Add_Click( {

            Push-Location -Path "scripts\"
            Clear-Host
            Get-ChildItem -Recurse *.ps*1 | Unblock-File
            $Scripts = @(
                # [Recommended order] List of Scripts
                "pkg-sw-installer.ps1"
            )
        
            ForEach ($FileName in $Scripts) {
                Title2Counter -Text "$FileName" -MaxNum $Scripts.Length
                Import-Module -DisableNameChecking .\"$FileName"
                #pause ### FOR DEBUGGING PURPOSES
            }

            Pop-Location
        
            ShowMessage -Title "$DoneTitle" -Message "$DoneMessage"
        })
    
    # Add all Panels to the Form (Screen)
    $Form.controls.AddRange(@($Panel1, $Panel2, $Panel3, $Panel4, $PictureBox1))
    
    # Show the Window
    [void]$Form.ShowDialog()
    
    # When done, dispose of the GUI
    $Form.Dispose()

}

Clear-Host                  # Clear the Powershell before it got an Output
QuickPrivilegesElevation    # Check admin rights
LoadLibs                    # Import modules from lib folder
UnrestrictPermissions       # Unlock script usage
SetupConsoleStyle           # Just fix the font on the PS console

PrepareGUI                  # Load the GUI

Write-Verbose "Restart: $Global:NeedRestart"
If ($Global:NeedRestart) {
    PromptPcRestart         # Prompt options to Restart the PC
}

RestrictPermissions         # Lock script usage
Taskkill /F /IM $PID        # Kill this task by PID because it won't exit with the command 'exit'