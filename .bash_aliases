# vim: set filetype=sh:

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
function bashreload()
{
  source "$HOME"/.bashrc
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

source ~/.bash_tmux

auto_tmux
