#!/bin/bash

# Set  up bash with some dependencies and configurations

update_apt() {

}

setup_root_perms() {
    sudo addgroup wheel
    sudo gpasswd -a $USER wheel
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