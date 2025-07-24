#!/bin/bash

# This script sets up Oh My Posh for zsh

clear
echo "##### Setting up Oh My Posh..."

# Check if a theme file is passed as a parameter
if [ -z "$1" ]; then
    echo "Error: No theme file provided. Please provide a theme file as the first parameter."
    exit 1
fi

theme_file="$1"

# Check if the theme file exists
if [ ! -f "$theme_file" ]; then
    echo "Error: The theme file '$theme_file' does not exist."
    exit 1
fi

# Dependency
sudo apt-get install -y unzip

# Install Oh My Posh
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin

### Update .zshrc if needed

zshrc_file="$HOME/.zshrc"

if ! grep -qF "export TERM=xterm-256color" $zshrc_file; then
    echo "export TERM=xterm-256color" >> $zshrc_file
fi

# Create ~/bin if it doesn't exist
[ -d "$HOME/bin" ] || mkdir "$HOME/bin"
if ! grep -qF "export PATH=\$PATH:/home/\$USER/bin" $zshrc_file; then
    echo 'export PATH=$PATH:/home/$USER/bin' >> $zshrc_file
fi

realpath=$(realpath $theme_file)
if ! grep -qF 'oh-my-posh init bash' $zshrc_file; then
    echo 'eval "$(oh-my-posh init zsh --config '$realpath')" ' >> ~/.zshrc
else 
    echo "Oh My Posh is already initialized in .zshrc"
fi

### Source .zshrc and restart shell

source ~/.zshrc
exec zsh
