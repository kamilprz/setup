#!/bin/bash

# Set up GPG for signing commits

echo ""
echo "##### Use same email on GPG as on Git config #####"
echo "##### Git config email is: " $(git config --global user.email)
git config --global --unset gpg.format

echo "##### Installing gnupg... #####"
sudo apt-get -y install gnupg
echo "##### Generating GPG key... #####"
gpg --full-generate-key

echo ""
echo "##### Setting up GPG key to sign commits #####"
echo "From the list of GPG keys, copy the long form of the GPG key ID you'd like to use - e.g. sec   4096R/***3AA5C34371567BD2***"
gpg --list-secret-keys --keyid-format=long

read -p "Enter the long form of the GPG key ID: " GPG_KEY
gpg --armor --export $GPG_KEY

echo ""
echo "##### Copy your GPG key, beginning with -----BEGIN PGP PUBLIC KEY BLOCK----- and ending with -----END PGP PUBLIC KEY BLOCK-----. #####"
echo "##### Add the key to your GitHub account -> https://github.com/settings/keys #####"

echo ""
echo "##### Navigate to the repo where you want to sign commits and run the following commands #####"
echo "git config user.signingkey $GPG_KEY"
echo "git config --add commit.gpgsign true"

# Bash by default
SHRC_FILE="$HOME/.bashrc"
# If current shell is ZSH, use .zshrc
if [[ "$(which $SHELL)" == *"zsh"* ]]; then
    SHRC_FILE="$HOME/.zshrc"
fi

# Add GPG_TTY (set to current terminal) to .*shrc if not already added
# This ensures that GPG can correctly prompt for passphrases and other input when running in a terminal session
if [ -f $SHRC_FILE ]; then
    if ! grep -q "export GPG_TTY=\$(tty)" $SHRC_FILE; then
        echo -e '\nexport GPG_TTY=$(tty)' >> $SHRC_FILE
        echo "Added GPG_TTY to $SHRC_FILE"
    else
        echo "GPG_TTY already present in $SHRC_FILE"
    fi
fi

source $SHRC_FILE
