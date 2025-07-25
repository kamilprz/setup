#!/bin/bash

# This script sets up Oh My Posh for zsh

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
if [ ! -f "$HOME/bin/oh-my-posh" ]; then
    echo "Installing Oh My Posh..."
    curl -s https://ohmyposh.dev/install.sh | bash -s -- -d "$HOME/bin"
else
    echo "Oh My Posh is already installed in $HOME/bin"
fi

# Bash by default
SHRC_FILE="$HOME/.bashrc"
# If current shell is ZSH, use .zshrc
if [[ "$(which $SHELL)" == *"zsh"* ]]; then
    SHRC_FILE="$HOME/.zshrc"
fi

if ! grep -qF "export TERM=xterm-256color" $SHRC_FILE; then
    echo "export TERM=xterm-256color" >> $SHRC_FILE
fi

# Create ~/bin if it doesn't exist
[ -d "$HOME/bin" ] || mkdir "$HOME/bin"
if ! grep -qF "export PATH=\$PATH:\$HOME/bin" $SHRC_FILE; then
    echo 'export PATH=$PATH:$HOME/bin' >> $SHRC_FILE
fi

realpath=$(realpath $theme_file)
if ! grep -qF 'oh-my-posh init' $SHRC_FILE; then
    echo 'eval "$(oh-my-posh init zsh --config '$realpath')" ' >> $SHRC_FILE
else 
    echo "Oh My Posh is already initialized in $SHRC_FILE"
fi

echo ""
echo "##### Configuration complete. Open up a new shell to apply the changes."