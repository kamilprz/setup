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

# Add GPG_TTY (set to current terminal) to .bashrc if not already added
# This ensures that GPG can correctly prompt for passphrases and other input when running in a terminal session
[ -f ~/.bashrc ] && echo -e '\nexport GPG_TTY=$(tty)' >> ~/.bashrc

source ~/.bashrc
