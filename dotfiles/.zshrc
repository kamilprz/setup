# Set up directories for config
ZSH_PLUGINS_DIR="$HOME/.config/zsh/plugins"
ZSH_CACHE_DIR="$HOME/.cache/zsh/"
mkdir -p "$ZSH_CACHE_DIR"

# Exports
export ZSH_COMPDUMP=$ZSH_CACHE_DIR/.zcompdump-$HOST
export TERM=xterm-256color
export PATH=$PATH:$HOME/bin
export PATH=$PATH:/snap/bin
export AWS_PROFILE=test-cli

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
bindkey '^f' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^o' cpbuffer

# Alias definitions
[ -f $HOME/.shell_aliases ] && source $HOME/.shell_aliases

# Plugins
# source "$ZSH_PLUGINS_DIR/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
# source "$ZSH_PLUGINS_DIR/zsh-completions/zsh-completions.plugin.zsh"
# source "$ZSH_PLUGINS_DIR/fzf-tab/fzf-tab.plugin.zsh"
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source "/opt/homebrew/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"

# tab completion
autoload -U compinit && compinit -d "$ZSH_COMPDUMP"
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
if (( $+commands[kubectl] )); then
  source <(kubectl completion zsh)
  compdef _kubectl k
fi

# Theme (Oh My Posh)
eval "$(oh-my-posh init zsh --config $HOME/src/setup/dotfiles/.config/oh-my-posh/kamp.omp.yaml)" 

# Tools
# source /usr/share/doc/fzf/examples/key-bindings.zsh
source /opt/homebrew/opt/fzf/shell/key-bindings.zsh

# Utilities
## fzf with bat preview 
ff() {
    local files=$(fzf -m --preview="bat --color=always {}")
    if [ -n "$files" ]; then
        code $files
    fi
}

# Syntax higlighting - should be last
# source "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
