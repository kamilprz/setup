## need admin shell

# install choco
# Set-ExecutionPolicy AllSigned
# Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Requires shell restart
# Add the DOOM_BIN to the PATH environment variable
$USERNAME = $env:USERNAME
$DOOM_BIN = "C:\Users\$USERNAME\.emacs.d\bin"
[System.Environment]::SetEnvironmentVariable('HOME', "C:\Users\$USERNAME\", 'Machine')
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";$DOOM_BIN", "Machine")
[System.Environment]::SetEnvironmentVariable("Path", $env:Path + ";C:\Program Files\Emacs\emacs-30.1\bin", "Machine")

cd $HOME

# install emacs
winget install --id=GNU.Emacs -e -v 30.1 
# dependencies
choco install git ripgrep -y
# optional dependencies
choco install fd llvm -y

# install font
choco install nerd-fonts-firacode

# within emacs run
# M-x nerd-icons-install-fonts

# install doom
git clone https://github.com/hlissner/doom-emacs .emacs.d

.emacs.d/bin/doom install

# can open doom with `emacs` afterwards


### Setting up emacs --daemon
# https://www.emacswiki.org/emacs/EmacsMsWindowsIntegration
# emacs shortcut - "C:\Program Files\Emacs\emacs-30.1\bin\emacsclientw.exe" -c -n -a ""


# mklink /d C:\Users\kamilp\OneDrive\notes C:\Users\kamilp\notes