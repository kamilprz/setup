#!/bin/bash

# Set  up bash with some dependencies and configurations

update_apt() {
    echo ""
    echo "##### Running apt-get update and upgrade... #####"
    sudo apt-get update -y
    sudo apt-get upgrade -y
}

setup_root_perms() {
    sudo addgroup wheel
    sudo gpasswd -a kamilp wheel
}

setup_repos() {
    bash retina.sh
}

setup_tools() {
    echo ""
    echo "##### Installing GNU Stow... #####"
    sudo apt-get install stow

    echo ""
    echo "##### Installing bat (batcat)... #####"
    sudo apt-get -y install bat

    echo ""
    echo "##### Installing fzf... #####"
    sudo apt install fzf
}


main() {
    clear
    update_apt
    setup_repos
    setup_tools

    source ~/.bashrc
}

main