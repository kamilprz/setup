# Stop displaying Edge tabs as windows when Alt-Tabbing

$regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
$valueName = "MultiTaskingAltTabFilter"
Get-RegistryKey -Path $regPath

$tabBehaviour = Get-ItemProperty -Path $regPath -Name $valueName
if ($tabBehaviour.MultiTaskingAltTabFilter -eq 3) {
    Write-Output ("Alt-Tab behaviour corrected.")
}
else {
    Write-Output ("Alt-Tab behaviour includes brower tabs, auto-disabling it...")
    Set-ItemProperty -Path $regPath -Name $valueName -Value 3 # Disable showing tabs
}
