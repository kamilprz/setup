# kamp.zsh-theme

autoload -Uz colors
colors

setopt prompt_subst

# Color palette
BLUE='%F{81}'        # ~ #56B6C2
LAVENDER='%F{147}'   # ~ #B4BEFE
RED='%F{160}'        # ~ #E36464
YELLOW='%F{3}'
RESET='%f%k'

# Start time tracking for execution time
preexec() {
  timer=${timer:-$EPOCHREALTIME}
}

precmd() {
  if [[ -n "$timer" ]]; then
    now=$EPOCHREALTIME
    elapsed=$(printf "%.0f" "$(echo "($now - $timer) * 1000" | bc)")
    if [[ "$elapsed" -ge 2000 ]]; then
      EXEC_TIME="${YELLOW}${elapsed}ms${RESET}"
    else
      EXEC_TIME=""
    fi
  fi
  timer=''
}

parse_git_branch() {
  git rev-parse --is-inside-work-tree &>/dev/null || return
  local branch git_status ahead behind
  branch=$(git symbolic-ref --short HEAD 2>/dev/null || git describe --tags --exact-match 2>/dev/null)
  git_status=$(git status --porcelain 2>/dev/null)
  ahead=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null | awk '{print $2}')
  behind=$(git rev-list --count --left-right @{upstream}...HEAD 2>/dev/null | awk '{print $1}')
  dirty=""
  [[ -n "$git_status" ]] && dirty="*"
  arrows=""
  [[ "$behind" -gt 0 ]] && arrows+="↓"
  [[ "$ahead" -gt 0 ]] && arrows+="↑"

  echo "${LAVENDER}git:${branch}${dirty} ${arrows}${RESET}"
}


# Prompt
PROMPT='${BLUE}%~${RESET} $(parse_git_branch)
${EXEC_TIME} ${LAVENDER}>${RESET} '

# Secondary prompt (for multiline commands)
RPROMPT=''
PS2="${LAVENDER}>>${RESET} "
