#!/bin/bash
# helpers for tmux status line scripts

function get_bgcolor_gradient_red_to_cyan() {
  local curval=${1:-0}
  local maxval=${2:-100}
  local maxindex=$(( ${#colors[@]} - 1 ))
  local index=$(( (curval * maxindex) / maxval ))
  local -a colors
  colors=(
    196 # red
    202 208 214 220 # oranges
    226 226 # yellow
    190 154 118 # yellow-greens
    046 046 046 # green
    047 048 049 050 # green-cyans
    051 # cyan
  )
  if [[ $index -gt $maxindex ]]; then
    index=$maxindex
  elif [[ $index -lt 0 ]]; then
    index=0
  fi
  echo ${COLORS[$GRADIENTINDEX]}
}

function needs_reboot() {
  [[ -f //var/run/reboot-required ]]
}
