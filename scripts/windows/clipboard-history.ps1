# Enable clipboard history
function Enable-ClipboardHistory {
    Get-RegistryKey -Path "HKCU:\Software\Microsoft\Clipboard"
    New-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 1 -PropertyType DWORD -Force
    Write-Output "Enabled Clipboard History"
}