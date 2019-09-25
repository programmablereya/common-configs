#!/bin/bash
# script for displaying reboot status in tmux status line

source "$( dirname "$(realpath -e "${BASH_SOURCE[0]}")" )"/.tmux.status-helpers.sh
if needs_reboot; then
  echo "#[bg=colour$(get_bgcolor_gradient_red_to_cyan 0 100)][REBOOT]"
fi
