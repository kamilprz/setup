#!/bin/bash

echo ""
echo "##### Setting up Bash Aliases #####"

bash_aliases_file="$HOME/.bash_aliases"

# Check if .bash_aliases exists; if not, create it
if [ ! -f "$bash_aliases_file" ]; then
    echo "Creating $bash_aliases_file..."
    touch "$bash_aliases_file"
else
    echo "$bash_aliases_file already exists."
fi

# Define aliases
ALIASES=(
    'alias k="kubectl"'
    'alias gs="git status"'
    'alias uncommit="git reset --soft HEAD~1"'
    'alias src="cd ~/src"'
    # 'alias ohmp="oh-my-posh"'
)

# Add each alias to ~/.bash_aliases if not already present
for ALIAS in "${ALIASES[@]}"; do
    if ! grep -Fxq "$ALIAS" ~/.bash_aliases; then
        echo "$ALIAS" >> ~/.bash_aliases
        echo "Added: $ALIAS"
    else
        echo "Already exists: $ALIAS"
    fi
done

# Check if .bashrc sources .bash_aliases; if not, add the source line
bashrc_file="$HOME/.bashrc"
source_aliases="if [ -f ~/.bash_aliases ]; then . ~/.bash_aliases; fi"

if ! grep -qF "$source_aliases" "$bashrc_file"; then
    echo "$source_aliases" >> "$bashrc_file"
    echo "Added source for .bash_aliases to $bashrc_file."
else
    echo ".bashrc already sources .bash_aliases."
fi

source ~/.bashrc

echo "Aliases updated!"