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

 function Fix-AltTabBehaviour {
    # Went and found this in Registry editor. Process Monitor from Sys Internals is another option
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
    $valueName = "MultiTaskingAltTabFilter"

    $tabBehaviour = Get-ItemProperty -Path $regPath -Name $valueName
    if ($tabBehaviour.MultiTaskingAltTabFilter -eq 3) {
        Write-Output ($GREEN + "Alt-Tab behaviour corrected.")
    } else {
        Write-Output ($YELLOW + "Alt-Tab behaviour includes brower tabs, auto-disabling it...")
        Set-ItemProperty -Path $regPath -Name $valueName -Value 3 # Disable showing tabs
    }
}

### Disable Bing Search in Windows Search
Ensure-RegistryKey -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -ErrorAction Stop
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search" -Name "CortanaConsent" -Value 0 -ErrorAction Stop
Write-Output "Disabled Bing Search in Windows"

### Disable Privacy settings
Write-Output "Disabling spyware..."
# Ensure ActivityFeed keys exist before setting properties
Ensure-RegistryKey -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ActivityFeed"
# Disable Activity History
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ActivityFeed" -Name "PublishUserActivities" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ActivityFeed" -Name "UploadUserActivities" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\ActivityFeed" -Name "SaveActivityHistory" -Value 0
# Ensure OnlineSpeechPrivacy key exists before setting properties
Ensure-RegistryKey -Path "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy"
# Disable Online Speech Recognition
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Speech_OneCore\Settings\OnlineSpeechPrivacy" -Name "HasAccepted" -Value 0
# Ensure DiagnosticDataViewer key exists before setting properties
Ensure-RegistryKey -Path "HKCU:\Software\Microsoft\DiagnosticDataViewer"
# Disable diagnostic data viewer
Set-ItemProperty -Path "HKCU:\Software\Microsoft\DiagnosticDataViewer" -Name "IsEnabled" -Value 0
# Ensure Siuf Rules key exists before setting properties
Ensure-RegistryKey -Path "HKCU:\Software\Microsoft\Siuf\Rules"
# Disable feedback frequency (sets to never prompt for feedback)
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "NumberOfSIUFInPeriod" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Siuf\Rules" -Name "PeriodInNanoSeconds" -Value 0
# Disable "Let apps show me personalized ads using my advertising ID"
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo' -Name 'Enabled' -Value 0 -ErrorAction Stop
# Disable "Let websites show me locally relevant content by accessing my language list"
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy' -Name 'AcceptedPrivacyPolicy' -Value 0 -ErrorAction Stop
# Disable "Let Windows improve Start and search results by tracking app launches"
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Start_TrackProgs' -Value 0 -ErrorAction Stop
# Disable "Show me suggested content in the Settings app"
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager' -Name 'SubscribedContent-338389Enabled' -Value 0 -ErrorAction Stop
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
# Disable advertising ID
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\AdvertisingInfo" -Name "Enabled" -Value 0
# Set diagnostic data level to "Basic" (0), or "Security" (1) on Enterprise editions
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\DataCollection" -Name "AllowTelemetry" -Value 0
# Disable Tailored Experiences with diagnostic data
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Privacy" -Name "TailoredExperiencesWithDiagnosticDataEnabled" -Value 0

### Disable showing tabs when alt-tabbing
Ensure-RegistryKey -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "AltTabSettings" -Value 1
Write-Output "Fixed Edge Alt-Tab"

Fix-AltTabBehaviour

### Show full right-click context menu in Windows 11
$registryPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
if (-not (Test-Path $registryPath)) {
    New-Item -Path $registryPath -Force
}
Set-ItemProperty -Path $registryPath -Name "(Default)" -Value "" -ErrorAction Stop
Write-Output "Enabled full right-click context menu"

### Show Hidden Files
Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'Hidden' -Value 1 -ErrorAction Stop
Write-Output "Set Show Hidden Files"

### Enable Clipboard History
New-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 1 -PropertyType DWORD -Force -ErrorAction Stop
Write-Output "Enabled Clipboard History"

### Set Dark Mode
$registryPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
Set-ItemProperty -Path $registryPath -Name "AppsUseLightTheme" -Value 0 -ErrorAction Stop
Set-ItemProperty -Path $registryPath -Name "SystemUsesLightTheme" -Value 0 -ErrorAction Stop
Write-Output "Set Dark Mode"

### Remove the search bar from the taskbar
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "SearchboxTaskbarMode" -Value 0 -Type DWord -Force -ErrorAction Stop
Write-Output "Removed the search bar from the taskbar"

### Align the taskbar to the left
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
Set-ItemProperty -Path $registryPath -Name "TaskbarAl" -Value 0 -Type DWord -Force -ErrorAction Stop
Write-Output "Aligned taskbar to the left"

### Restart Windows Explorer to apply the changes
Stop-Process -Name explorer -Force
Write-Output "Restarted Windows Explorer"

#### Configure WSL
wsl --update
Write-Output "WSL updated"