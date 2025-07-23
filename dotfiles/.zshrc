export TERM=xterm-256color
export PATH=$PATH:/home/$USER/bin

# Keybinds
bindkey -e
bindkey '^f' autosuggest-accept
bindkey '^p' history-search-backward
bindkey '^n' history-search-forward
bindkey '^o' cpbuffer

# Aliases
alias ls="lsd"
alias ll='ls -alF'
alias la='ls -A'
alias tree="ls --tree"
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias src="cd ~/src"
alias k="kubectl"
alias gs="git status"
alias uncommit="git reset --soft HEAD~1"
alias sourc="source ~/.zshrc"
alias glog="git log -25"

# Plugins
ZSH_PLUGINS_DIR="$HOME/.config/zsh/plugins"
mkdir -p "$ZSH_PLUGINS_DIR"

# Install a plugin from GitHub if it doesn't exist & source it
plugin() {
    local repo_path=$1
    local plugin_name="${repo_path##*/}"
    local plugin_dir="$ZSH_PLUGINS_DIR/$plugin_name"

    if [ ! -d "$plugin_dir" ]; then
        echo "Plugin $plugin_name is missing, installing ..."
        git clone --depth 1 "https://github.com/$repo_path.git" "$plugin_dir"
        echo ""
    fi

    source "$plugin_dir/$plugin_name.plugin.zsh"
}

plugin "zsh-users/zsh-autosuggestions"
plugin "zsh-users/zsh-completions"
plugin "Aloxaf/fzf-tab"
plugin "zsh-users/zsh-syntax-highlighting"

# install kubectl, azure, helm?

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

### # clip.exe is a Windows utility (WSL)

## Copy current directory path to clipboard
function cpdir() {
  local file="${1:-.}"
  [[ $file = /* ]] || file="$PWD/$file"
  print -n "${file:a}" | clip.exe || return 1

  echo "${(%):-"Path of %B${file:a}%b copied to clipboard."}"
}

## Copy file content to clipboard
function cpfile() {
    clip.exe < "$1" || return 1
    echo "${(%):-"Content of %B$1%b copied to clipboard."}"
}

## Copy buffer content to clipboard
function cpbuffer () {
    echo $BUFFER | clip.exe || return 1
}
zle -N cpbuffer

