#!/bin/bash
# vim: set filetype=sh:

# tmux configuration files are found alongside this file
export TMUX_CONF_DIR=${TMUX_CONF_DIR:-"$( dirname "$(realpath -e "${BASH_SOURCE[0]}")" )"}
# default status script just shows whether a reboot is needed
export TMUX_STATUS_SCRIPT=${TMUX_STATUS_SCRIPT:-"$TMUX_CONF_DIR/.tmux.need-reboot.sh"}

function tmux_has_main() {
  tmux -2 has-session -t "Main Screen"
}

function tmux_init_main() {
  tmux -2 new-session -d -s "Main Screen" -n "Misc."
  tmux -2 new-window -d -t "Main Screen:0" -n "Monitor" "htop"
}

function go_tmux ()
{
  if [[ "$TERM" == screen* ]]; then
    echo "Screenception is not permitted."
    return 1;
  fi
  sleep 1s
  echo "Starting tmux..."
  tmux_has_main || tmux_init_main || return 1
  if [[ $1 == "-x" ]]; then
    exec tmux -2 attach-session -t "Main Screen" || return 1
  else
    tmux -2 attach-session -t "Main Screen" || return 1
  fi
}

function auto_tmux ()
{
  if [[ -n "$PS1" ]] && [[ "$TERM" != screen* ]] && [[ -z "$ALREADY_TRIED_STARTING_TMUX" ]]; then
    ALREADY_TRIED_STARTING_TMUX=true
    echo "Switching to tmux, press Ctrl+C to cancel...";
    sleep 1s && go_tmux -x
  fi
}
