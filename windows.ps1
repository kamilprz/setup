#### RUN ME AS ADMIN

#### Configure Windows Settings

# Function to check if a registry key exists and create it if not
function Ensure-RegistryKey {
    param (
        [string]$Path
    )
    if (-not (Test-Path $Path)) {
        New-Item -Path $Path -Force | Out-Null
    }
}

# Stop displaying Edge tabs as windows when Alt-Tabbing
 function Fix-AltTabBehaviour {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $valueName = "MultiTaskingAltTabFilter"

    $tabBehaviour = Get-ItemProperty -Path $regPath -Name $valueName
    if ($tabBehaviour.MultiTaskingAltTabFilter -eq 3) {
        Write-Output ("Alt-Tab behaviour corrected.")
    } else {
        Write-Output ("Alt-Tab behaviour includes brower tabs, auto-disabling it...")
        Set-ItemProperty -Path $regPath -Name $valueName -Value 3 # Disable showing tabs
    }
}

# Disable Bing search in Windows search
function Disable-BingSearch {
    Ensure-RegistryKey -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0
    Write-Output "Disabled Bing Search in Windows."
}

# Disable various privacy settings
function Disable-PrivacySettings {
    Write-Output "Disabling spyware..."

    # Ensure ActivityFeed keys exist before setting properties
    Ensure-RegistryKey -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ActivityFeed"
    # Disable Activity History
    Ensure-RegistryKey -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ActivityFeed"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ActivityFeed" -Name "PublishUserActivities" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ActivityFeed" -Name "UploadUserActivities" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ActivityFeed" -Name "SaveActivityHistory" -Value 0

    # Disable Online Speech Recognition
    Ensure-RegistryKey -Path "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Value 0

    # Disable Diagnostic Data Viewer
    Ensure-RegistryKey -Path "HKCU:\Software\Microsoft\DiagnosticDataViewer"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\DiagnosticDataViewer" -Name "IsEnabled" -Value 0

    # Disable Feedback Frequency
    Ensure-RegistryKey -Path "HKCU:\Software\Microsoft\Siuf\Rules"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds" -Value 0

    # Disable Advertising ID
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0

    # Disable other Privacy Settings
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "AcceptedPrivacyPolicy" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Start_TrackProgs" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" -Name "SubscribedContent-338389Enabled" -Value 0

    # Disable location access for all users
    Set-ItemProperty -Path "HKLM:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\location" -Name "Value" -Value "Deny"

    # Disable diagnostic data sharing
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "UserExperiences" -Value 0

    # Disable sending typing and inking data to Microsoft
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Personalization\Settings" -Name "AcceptedPrivacyPolicy" -Value 0

    # Disable getting to know you (typing and inking personalization)
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitTextCollection" -Value 1
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\InputPersonalization" -Name "RestrictImplicitInkCollection" -Value 1

    # Disable app access to account info
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\userDataTasks" -Name "Value" -Value "Deny"

    # Disable access to contacts
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CapabilityAccessManager\ConsentStore\contacts" -Name "Value" -Value "Deny"

    # Set diagnostic data level to "Basic" (0), or "Security" (1) on Enterprise editions
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0

    Write-Output "Privacy settings disabled."
}

# Enable full right-click context menu
function Enable-FullContextMenu {
    $registryPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force
    }
    Set-ItemProperty -Path $registryPath -Name "(Default)" -Value ""
    Write-Output "Enabled full right-click context menu."
}

# Show hidden files
function Show-HiddenFiles {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "Hidden" -Value 1
    Write-Output "Set Show Hidden Files."
}

# Enable clipboard history
function Enable-ClipboardHistory {
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 1 -PropertyType DWORD -Force
    Write-Output "Enabled Clipboard History"
}

# Set dark mode
function Set-DarkMode {
    $registryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    Set-ItemProperty -Path $registryPath -Name "AppsUseLightTheme" -Value 0
    Set-ItemProperty -Path $registryPath -Name "SystemUsesLightTheme" -Value 0
    Write-Output "Set Dark Mode."
}

# Remove the search bar from the taskbar
function Remove-SearchBar {
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Type DWord
    Write-Output "Removed the search bar from the taskbar."
}

# Function to align the taskbar to the left
function Align-TaskbarLeft {
    $registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    Set-ItemProperty -Path $registryPath -Name "TaskbarAl" -Value 0 -Type DWord
    Write-Output "Aligned taskbar to the left."
}

# Set the desktop wallpaper
function Set-Wallpaper {
    param (
        [string]$imagePath
    )
    $SPI_SETDESKWALLPAPER = 0x0014
    $SPIF_UPDATEINIFILE = 0x01
    $SPIF_SENDCHANGE = 0x02
    [Wallpaper]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $imagePath, $SPIF_UPDATEINIFILE -bor $SPIF_SENDCHANGE)
    Write-Output "Wallpaper has been changed to $imagePath."
}

# Restart Windows Explorer
function Restart-Explorer {
    Stop-Process -Name explorer -Force
    Write-Output "Restarted Windows Explorer."
}

# Update WSL
function Update-WSL {
    wsl --update
    Write-Output "WSL updated."
}


###############################################


Fix-AltTabBehaviour
Disable-BingSearch
Disable-PrivacySettings
Enable-FullContextMenu
Show-HiddenFiles
Enable-ClipboardHistory
Set-DarkMode
Remove-SearchBar
Align-TaskbarLeft
Set-Wallpaper -imagePath "C:\Windows\Web\Wallpaper\ThemeB\img25.jpg"

Restart-Explorer

Update-WSL

### Manual touches
Write-Output "To change the colour of mouse cursor -> Win+U -> Mouse Pointer and Touch -> Custom -> #21FFFB"


