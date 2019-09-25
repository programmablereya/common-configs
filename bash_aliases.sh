#!/bin/bash
# vim: set filetype=sh:
# link destination: $HOME/.bash_aliases

# Install EDITOR
export EDITOR='vim -X'

# Update SSH_AUTH_SOCK
sock_proxy=$HOME/.ssh/ssh_auth_sock
if [ -S "$(readlink $sock_proxy)" ]; then
  SSH_AUTH_SOCK=$sock_proxy
fi

alias rm="rm -i"
alias cp="cp -i"
alias mv="mv -i"
alias vim="vim -X"

# Send a bell before the prompt if it has been a long time since the last
# prompt.
# function bell_on_long_running_commands() {
#   local NOW=`date -u +%s`
#   if [ $(( LASTCMD_FOR_BELLS )) -lt $(( NOW - 15 )) ]; then
#     echo -n $'\a'
#   fi
#   unset LASTCMD_FOR_BELLS;
# }
# function set_last_command_time() {
#   if [[ -z "${COMPLINE}" ]] && [[ -z "${LASTCMD_FOR_BELLS}" ]]; then
#     LASTCMD_FOR_BELLS=`date -u +%s`
#   fi
# }
# trap set_last_command_time DEBUG
# export PROMPT_COMMAND=bell_on_long_running_commands
function bell_after() {
  "$@"
  local exit="$?"
  echo -n $'\a' 1>&2
  return "$exit"
}

# Reload aliases
function reload_scripts_only()
{
  source "$HOME"/.bashrc
}

# from https://stackoverflow.com/a/1203628
# Useful for overriding functions defined in these common scripts
# Usage: copy_func from to
function copy_func()
{
    declare -F $1 > /dev/null || return 1
    eval "$(echo "${2}()"; declare -f ${1} | tail -n +2)"
}

function sync_git_only()
{
  (
    cd "$( dirname "$(realpath -e "${BASH_SOURCE[0]}")" )"
    needs_push=false
    if git add . && ! git diff-index --cached --quiet HEAD; then
      git commit -am "Autocommitted updated scripts from ${hostname}"
      needs_push=true
    fi
    git pull --rebase
    if [[ "$needs_push" == "true" ]]; then
      git push
    fi
  )
}

alias ssh-keygen="ssh-keygen -o -a 100 -t ed25519"

function ssh-authorize-key() {
  cat "$1" >>~/.ssh/authorized_keys
}

function bashreload()
{
  reload_scripts_only
  sync_git_only
  reload_scripts_only
}

function man ()
{
  command man "$@" 2>/dev/null || builtin help -m "$@" 2>/dev/null || command man "$@"
}

function help ()
{
  builtin help -m "$@" 2>/dev/null || command man "$@" 2>/dev/null || builtin help -m "$@"
}

PS1='\[\e[1;31m\]${debian_chroot:+($debian_chroot)}\[\e[0;36m\]\u\[\e[0;33m\]@\[\e[34m\]\h\[\e[0m\]:\[\e[1;32m\]\w\[\e[0m\]\n\$ '

source "$( dirname "$(realpath -e "${BASH_SOURCE[0]}")" )"/bash_tmux.sh
