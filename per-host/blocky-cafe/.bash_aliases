source ~/.bash_aliases-common

copy_func tmux_init_main tmux_init_main_base

function tmux_init_main() {
  tmux_init_main_base
  tmux -2 new-window -d -t "Main Screen:1" -n "Server" "~/current-server/mark2/start; ~/current-server/mark2/attach"
}

auto_tmux
