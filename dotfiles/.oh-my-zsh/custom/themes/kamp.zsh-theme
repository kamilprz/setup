# kamp.zsh-theme

# Color palette
BLUE='%F{81}'       # ~ #56B6C2
LAVENDER='%F{147}'  # ~ #B4BEFE
RED='%F{160}'       # ~ #E36464
YELLOW='%F{3}'


# --- Git  ---
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

  echo "${LAVENDER}git:${branch}${dirty} ${BLUE}${arrows}"
}


# --- Execution Timer ---
YELLOW_TIMER=$'\033[0;33m'

# Start timer before execution of a command
preexec() {
  timer=${EPOCHREALTIME}
}
    
# Display elapsed time after command execution / before prompt
precmd() {
  if [[ -n "$timer" ]]; then
    now=${EPOCHREALTIME}
    elapsed=$(echo "$now - $timer" | bc -l)
    total_ms_int=$(printf "%.0f" $(echo "$elapsed * 1000" | bc -l))
    
    h=$(($total_ms_int / 3600000))
    m=$(($total_ms_int % 3600000 / 60000))
    s=$(($total_ms_int % 60000 / 1000))
    ms=$(($total_ms_int % 1000))
    
    formatted_time=""
    [[ $h -gt 0 ]] && formatted_time="${h}h"
    [[ $m -gt 0 ]] && formatted_time="${formatted_time}${formatted_time:+ }${m}m"
    [[ $s -gt 0 ]] && formatted_time="${formatted_time}${formatted_time:+ }${s}s"
    [[ $ms -gt 0 ]] && formatted_time="${formatted_time}${formatted_time:+ }${ms}ms"
    
    echo "\r${YELLOW_TIMER}${formatted_time}"
  fi
  unset timer
}


# --- Prompt ---
PROMPT='${BLUE}%~ $(parse_git_branch)
${LAVENDER}> '
