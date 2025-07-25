#!/bin/bash

# Backup existing dotfiles and create symlinks for the new ones
echo "##### Backing up existing dotfiles & creating new symlinks ... #####";

CACHE_DIR="$HOME/.cache/backup/"
mkdir -p "$CACHE_DIR"

# Function to handle dotfile setup
setup_dotfile() {
    local source_file="$1"
    local target_file="$2"
    local backup_name="$3"
    
    # If it's a symlink, just remove it (we'll recreate it)
    if [ -L "$target_file" ]; then
        rm -f "$target_file"
    # If it's a regular file/directory, back it up
    elif [ -e "$target_file" ]; then
        mv "$target_file" "$CACHE_DIR/$backup_name"
    fi
    
    # Create the new symlink
    ln -s $(realpath "$source_file") "$target_file"
}

# Setup each dotfile
setup_dotfile "./dotfiles/.bashrc"          "$HOME/.bashrc"         ".bashrc.bak"
setup_dotfile "./dotfiles/.zshrc"           "$HOME/.zshrc"          ".zshrc.bak"
setup_dotfile "./dotfiles/.shell_aliases"   "$HOME/.shell_aliases"  ".shell_aliases.bak"
setup_dotfile "./dotfiles/.config"          "$HOME/.config"         ".config.bak"
setup_dotfile "./dotfiles/.gitconfig"       "$HOME/.gitconfig"      ".gitconfig.bak"
setup_dotfile "./dotfiles/.bookmarks"       "$HOME/.bookmarks"      ".bookmarks.bak"