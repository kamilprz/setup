# Set up directorires for config
BASH_CACHE_DIR="$HOME/.cache/bash/"
mkdir -p "$BASH_CACHE_DIR"

# Options
shopt -s checkwinsize
shopt -s globstar

# Completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# History
HISTFILE="$BASH_CACHE_DIR/history"
HISTCONTROL=ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend

# Alias definitions
[ -f $HOME/.shell_aliases ] && source $HOME/.shell_aliases

# Tools
source /usr/share/doc/fzf/examples/key-bindings.bash

# Utilities
ff() {
    local files=$(fzf -m --preview="batcat --color=always {}")
    if [ -n "$files" ]; then
        code $files
    fi
}

# Environment Variables / Path
# export PATH=$PATH:/home/kamilp/src/retina/bin
export PATH=$PATH:/home/$USER/src/retina/artifacts
export TERM=xterm-256color
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/snap/bin
export PATH=$PATH:$HOME/bin
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export GPG_TTY=$(tty)
export KUBECONFIG=/mnt/c/Users/$USER/.kube/config

# Theme (Oh My Posh)
eval "$(oh-my-posh init bash --config /home/$USER/src/setup/dotfiles/.config/oh-my-posh/kamp.omp.yaml)" 
