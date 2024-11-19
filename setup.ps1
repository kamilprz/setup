.\windows.ps1

wsl bash wsl.sh

# Restart WSL
wsl --shutdown

wsl bash create-aks-cluster.sh