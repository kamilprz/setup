export TERM=xterm-256color
export PATH=$PATH:/home/$USER/bin

# Keybinds
bindkey -e
bindkey '^f' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward

# Aliases
alias ls='ls --color=auto'

# Plugins
source ~/.config/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh
source ~/.config/zsh/plugins/zsh-completions/zsh-completions.plugin.zsh
source ~/.config/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh
source ~/.config/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh

# Load completions
autoload -U compinit && compinit

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors 'di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'

# History
HISTFILE=~/.zsh_history
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

# Theme (Oh My Posh)
eval "$(oh-my-posh init zsh --config /home/kamilp/src/setup/dotfiles/.config/oh-my-posh/kamp.omp.yaml)" 

# Tools
source /usr/share/doc/fzf/examples/key-bindings.zsh

# Utilities
ff() {
    local files=$(fzf -m --preview="batcat --color=always {}")
    if [ -n "$files" ]; then
        code $files
    fi
}