#!/bin/bash

clear
echo "##### Setting up Oh My Posh..."

bashrc_file="$HOME/.bashrc"

if ! grep -qF "export TERM=xterm-256color" "$bashrc_file"; then
    echo "export TERM=xterm-256color" >> "$bashrc_file"
fi

# Dependency
sudo apt-get install unzip

# Create ~/bin if it doesn't exist
[ -d "$HOME/bin" ] || mkdir "$HOME/bin"

if ! grep -qF "export PATH=$PATH:/home/kamilp/bin" "$bashrc_file"; then
    echo 'export PATH=$PATH:/home/kamilp/bin' >> "$bashrc_file"
fi

# Install
curl -s https://ohmyposh.dev/install.sh | bash -s

# By default goes into ~/bin
curl -s https://ohmyposh.dev/install.sh | bash -s -- -d ~/bin

# Check if ~/.bashrc contains the line with 'oh-my-posh init bash'
if grep -q 'oh-my-posh init bash' ~/.bashrc; then
    # If found, delete the line
    sed -i '/oh-my-posh init bash/d' ~/.bashrc
fi

# Set my custom theme
echo 'eval "$(oh-my-posh init bash --config '$HOME/src/setup/themes/kamp.omp.yaml')"' >> ~/.bashrc

source ~/.bashrc
exec bash