# Set up directories for config
ZSH_PLUGINS_DIR="$HOME/.config/zsh/plugins"
ZSH_CACHE_DIR="$HOME/.cache/zsh/"
mkdir -p "$ZSH_CACHE_DIR"

# Exports
export ZSH_COMPDUMP=$ZSH_CACHE_DIR/.zcompdump-$HOST
export TERM=xterm-256color
export PATH=$PATH:$HOME/bin
export PATH=$PATH:/usr/local/go/bin
export PATH=$PATH:/snap/bin
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
export GPG_TTY=$(tty)
export KUBECONFIG=/mnt/c/Users/$USER/.kube/config

# History
HISTFILE="$ZSH_CACHE_DIR/history"
HISTSIZE=5000
SAVEHIST=$HISTSIZE
HISTDUP=erase
setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

# Keybinds
bindkey -e
bindkey '^f' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^o' cpbuffer

# Alias definitions
[ -f $HOME/.shell_aliases ] && source $HOME/.shell_aliases

# Plugins
source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
source "$ZSH_PLUGINS_DIR/zsh-completions/zsh-completions.plugin.zsh"
source "$ZSH_PLUGINS_DIR/fzf-tab/fzf-tab.plugin.zsh"

# Completions
## Load
autoload -U compinit && compinit -d "$ZSH_COMPDUMP"
## Kubectl completion
if (( $+commands[kubectl] )); then
  source <(kubectl completion zsh)
  compdef _kubectl k
fi
## Styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors 'di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# Theme (Oh My Posh)
eval "$(oh-my-posh init zsh --config /home/$USER/src/setup/dotfiles/.config/oh-my-posh/kamp.omp.yaml)" 

# Tools
source /usr/share/doc/fzf/examples/key-bindings.zsh

# Utilities
## fzf with bat preview 
ff() {
    local files=$(fzf -m --preview="batcat --color=always {}")
    if [ -n "$files" ]; then
        code $files
    fi
}

# Syntax higlighting - should be last
source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
