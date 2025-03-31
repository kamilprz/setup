#!/bin/bash

# Set  up bash with some dependencies and configurations

update_apt() {
    clear
    echo ""
    echo "##### Running apt-get update and upgrade... #####"
    # Update package list
    sudo apt-get -y update
    # Upgrade packages
    sudo apt-get -y upgrade
}

setup_root_perms() {
    sudo addgroup wheel
    sudo gpasswd -a kamilp wheel
}

install_tools() {
    clear
    echo ""
    echo "##### Setting up tools... #####"

    echo ""
    echo "##### Installing GNU Stow... #####"
    sudo apt-get -y install stow

    echo ""
    echo "##### Installing bat (batcat)... #####"
    sudo apt-get -y install bat

    echo ""
    echo "##### Installing fzf... #####"
    sudo apt-get -y install fzf

    echo ""
    echo "##### Installing lsd... #####"
    sudo apt-get -y install lsd

    echo ""
    echo "##### Installing GitHub (gh) cli... #####"
    sudo apt install gh

    # echo "##### Installing Go... #####"
    # sudo apt-get -y install golang-go
    # sudo snap install golangci-lint --classic
}

setup_symlinks_for_dotfiles(){
    cd ~/dotfiles
    # create the symlinks
    stow .
}

login_gh(){
    echo ""
    echo "##### Logging into gh cli #####"
    gh auth login
}

main() {
    update_apt
    setup_tools
    setup_symlinks_for_dotfiles
    login_gh
    source ~/.bashrc
}

main