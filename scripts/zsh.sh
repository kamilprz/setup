#!/bin/bash

# Work In Progress - this script will set up zsh and OhMyZsh

# Install zsh
sudo apt install zsh

# Install OhMyZsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Copy my theme into .oh-my-zsh\custom\themes

# chsh -s $(which zsh)