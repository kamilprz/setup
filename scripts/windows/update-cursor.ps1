# Changes the cursor based on .cur files in the specified folder

# Define the folder containing the .cur files
$cursorFolder = Join-Path -Path $PSScriptRoot -ChildPath "windows_cursor"

# Ensure the folder exists
if (-not (Test-Path $cursorFolder)) {
    Write-Error "The specified folder does not exist: $cursorFolder"
    return
}

# Define the list of cursor roles and their default filenames
$cursorRoles = @{
    "AppStarting" = "busy_eoa.cur"
    "Arrow"       = "arrow_eoa.cur"
    "Crosshair"   = "cross_eoa.cur"
    "Hand"        = "link_eoa.cur"
    "Help"        = "helpsel_eoa.cur"
    "IBeam"       = "ibeam_eoa.cur"
    "No"          = "unavail_eoa.cur"
    "NWPen"       = "pen_eoa.cur"
    "Person"      = "person_eoa.cur"
    "Pin"         = "pin_eoa.cur"
    "SizeAll"     = "move_eoa.cur"
    "SizeNESW"    = "nesw_eoa.cur"
    "SizeNS"      = "ns_eoa.cur"
    "SizeNWSE"    = "nwse_eoa.cur"
    "SizeWE"      = "ew_eoa.cur"
    "UpArrow"     = "up_eoa.cur"
    "Wait"        = "wait_eoa.cur"
}

# Loop through each cursor role and update its registry value
foreach ($role in $cursorRoles.Keys) {
    $cursorFile = Join-Path -Path $cursorFolder -ChildPath $cursorRoles[$role]
    if (Test-Path $cursorFile) {
        # Set the registry value for the cursor
        Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name $role -Value $cursorFile
    }
    else {
        Write-Warning "Cursor file not found $cursorFile"
    }
}

# Apply the changes by refreshing system parameters
rundll32.exe user32.dll, UpdatePerUserSystemParameters
Write-Output "Cursor scheme updated successfully."