# Enable clipboard history (Win + V)

New-ItemProperty -Path "HKCU:\Software\Microsoft\Clipboard" -Name "EnableClipboardHistory" -Value 1 -PropertyType DWORD
Write-Output "Enabled Clipboard History"