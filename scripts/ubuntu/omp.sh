#!/bin/bash

# This script sets up Oh My Posh

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

### Update .bashrc if needed

bashrc_file="$HOME/.bashrc"

if ! grep -qF "export TERM=xterm-256color" $bashrc_file; then
    echo "export TERM=xterm-256color" >> $bashrc_file
fi

# Create ~/bin if it doesn't exist
[ -d "$HOME/bin" ] || mkdir "$HOME/bin"
if ! grep -qF "export PATH=\$PATH:/home/\$USER/bin" $bashrc_file; then
    echo 'export PATH=$PATH:/home/$USER/bin' >> $bashrc_file
fi

realpath=$(realpath $theme_file)
if ! grep -qF 'oh-my-posh init bash' $bashrc_file; then
    echo 'eval "$(oh-my-posh init bash --config '$realpath')" ' >> ~/.bashrc
else 
    echo "Oh My Posh is already initialized in .bashrc"
fi

### Source .bashrc and restart shell

source ~/.bashrc
exec bash
