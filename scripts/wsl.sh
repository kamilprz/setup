#!/bin/bash

update_system() {
    echo ""
    echo "##### Running apt-get update and upgrade..."
    sudo apt-get update -y
    sudo apt-get upgrade -y
}

setup_repos() {
    bash retina.sh
}

configure_ghcr() {
    echo ""
    echo "##### Configuring GHCR Credentials #####"
    echo "Go to https://github.com/settings/tokens/new and create a token with the following scopes:"
    echo "- repo"
    echo "- workflows"
    echo "- write:packages"
    echo "- delete:packages"
    echo "- read:org"
    echo ""
    read -p "Enter your GHCR token: " USER_INPUT
    export CR_PAT=$USER_INPUT
    echo $CR_PAT | docker login ghcr.io -u USERNAME --password-stdin
}

configure_git() {
    echo ""
    echo "##### Setting up Git #####"
    echo "##### Use same email on GPG as on Git #####"

    read -p "Enter your GH email: " USER_EMAIL
    git config --global user.email "$USER_EMAIL"
    read -p "Enter your GH name: " USER_NAME
    git config --global user.name "$USER_NAME"

    git config --global --unset gpg.format

    sudo apt-get -y install gnupg
    gpg --full-generate-key

    echo ""
    echo "##### Setting up GPG key to sign commits #####"
    echo "From the list of GPG keys, copy the long form of the GPG key ID you'd like to use - e.g. sec   4096R/***3AA5C34371567BD2***"
    gpg --list-secret-keys --keyid-format=long

    read -p "Enter the long form of the GPG key ID: " GPG_KEY
    gpg --armor --export $GPG_KEY

    echo ""
    echo "##### Copy your GPG key, beginning with -----BEGIN PGP PUBLIC KEY BLOCK----- and ending with -----END PGP PUBLIC KEY BLOCK-----. #####"
    echo "##### Add the key to your GitHub account. https://docs.github.com/en/authentication/managing-commit-signature-verification/adding-a-gpg-key-to-your-github-account #####"

    cd ~/src/retina
    git config user.signingkey $GPG_KEY
    git config --add commit.gpgsign true

    [ -f ~/.bashrc ] && echo -e '\nexport GPG_TTY=$(tty)' >> ~/.bashrc

    echo ""
    echo "##### Logging into GitHub CLI #####"
    gh auth login
}

setup_aliases() {
    bash aliases.sh
}

setup_root_perms() {
    sudo addgroup wheel
    sudo gpasswd -a kamilp wheel
}

main() {
    clear
    update_system
    setup_repos
    configure_ghcr
    configure_git
    setup_aliases
    source ~/.bashrc
}

main