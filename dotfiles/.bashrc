# If not running interactively, don't do anything.
case $- in
    *i*) ;;
      *) return;;
esac

# Check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# Make less more friendly for non-text input files.
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Colored GCC warnings and errors.
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# Enable color support of ls.
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"

fi

# Enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

### History

# Don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth

# Append to the history file, don't overwrite it.
shopt -s histappend

# For setting history length see HISTSIZE and HISTFILESIZE in bash(1).
HISTSIZE=1000
HISTFILESIZE=2000

### Alias definitions

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

### fzf

# Set up fzf key bindings and fuzzy completion.
source /usr/share/doc/fzf/examples/key-bindings.bash

# Alias for fzf.
# Multiple selection, bat preview, and opening in vscode.
# If no files are selected, nothing happens.
ff() {
    local files=$(fzf -m --preview="batcat --color=always {}")
    if [ -n "$files" ]; then
        code $files
    fi
}

git-sync() {
  git fetch upstream
  git pull upstream main
  git push
}

make-debug-pod() {
  kubectl run -i --tty debug --image=alpine -- sh
}

delete-debug-pod() {
  kubectl delete pod debug
}

remake-cli() {
  uncommit
  git add .
  git commit -m "debugging"
  make kubectl-retina-image
}

# Customize default behaviour of fzf.
# export FZF_DEFAULT_COMMAND='fd --type f'

### Environment Variables / Path

# export PATH=$PATH:/home/kamilp/src/retina/bin
export PATH=$PATH:/home/$USER/src/retina/artifacts
export TERM=xterm-256color
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/home/$USER/bin
### Oh My Posh
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export GPG_TTY=$(tty)
export KUBECONFIG=/mnt/c/Users/$USER/.kube/config
eval "$(oh-my-posh init bash --config /home/$USER/src/setup/dotfiles/.config/oh-my-posh/kamp.omp.yaml)" 
