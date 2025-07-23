#!/bin/bash

# Install zsh
sudo apt install zsh

# Change shell to zsh
sudo chsh $USER -s $(which zsh)