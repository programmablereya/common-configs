#!/bin/bash
. ~/.bash_aliases-common

if [[ -f ~/.bash_tools ]]; then
  . ~/.bash_tools
fi

auto_tmux

function tmux_start_branch() {
  (
    branch=${1:?}
    tmux -2 new-window -a -t "Main Screen:1" -c ~ -e BRANCH_NAME="$branch" 'bash -ic "start_branch \"\$BRANCH_NAME\"; exec bash"'
  )
}

function start_branch() {
  (
    set -eu
    branch=${1:?}
    if [[ ! -d ~/branches/"$branch" ]]; then
      printf "=== Setting up a branch named ${branch}...\n"
      cd ~/.equalizer
      printf "=== Retrieving the latest data from the repository...\n"
      git fetch --all
      printf "=== Creating the branch 'feature/${branch}' from develop_front and checking it out in a new working tree at ~/branches/${branch}...\n"
      git worktree add -b "feature/${branch}" ~/branches/"${branch}" develop_front
    else
      printf "=== Accessing an existing branch named ${branch}...\n"
    fi
    cd ~/branches/"${branch}"
    update_branch
    printf "\a=== Your new branch ${branch} is ready!\n"
  ) && \
  cd ~/branches/"${branch}"
}

function update_branch() {
  (
    printf "=== Updating the branch...\n"
    git fetch --all
    git pull --rebase
    git rebase --interactive develop_front
    printf "=== Updating the dependencies...\n"
    install_equalizer_deps
  )
}

function install_equalizer_deps() {
  (
    set -eu
    printf "Installing Ruby dependencies...\n"
    bundle install
    printf "Installing Javascript dependencies...\n"
    printf "Installing in top level...\n"
    yarn install
    printf "Installing in widget...\n"
    pushd widget
    yarn install
    yarn build
    popd
    printf "Installing in front...\n"
    pushd front
    yarn install
  )
}
