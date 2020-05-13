#!/bin/bash
. ~/.bash_aliases-common

if [[ -f ~/.bash_tools ]]; then
  . ~/.bash_tools
fi

auto_tmux

function tmux_start_branch() {
  (
    # set -o errexit # Can't do this inside a function
    set -o nounset
    set -o pipefail
    branch=${1:?}
    tmux -2 new-window -a -t "Main Screen:1" -c ~ -e BRANCH_NAME="$branch" 'bash -ic "start_branch \"\$BRANCH_NAME\"; exec bash"'
  )
}


function start_branch() {
  branch=${1:?}
  (
    # set -o errexit # Can't do this inside a function
    set -o nounset
    set -o pipefail
    if [[ ! -d ~/branches/"$branch" ]]; then
      printf "=== Setting up a branch named ${branch}...\n"
      cd ~/equalizer.git || exit "$?"
      printf "=== Retrieving the latest data from the repository...\n"
      git fetch --all || exit "$?"
      printf "=== Creating the branch 'feature/${branch}' from develop_front and checking it out in a new working tree at ~/branches/${branch}...\n"
      git worktree add -b "feature/${branch}" ~/branches/"${branch}" develop_front || git worktree add ~/branches/"${branch}" "feature/${branch}" || exit "$?"
    else
      printf "=== Accessing an existing branch named ${branch}...\n"
    fi
    cd ~/branches/"${branch}" || exit "$?"
    update_branch || exit "$?"
    printf "\a=== Your new branch ${branch} is ready!\n"
  )
  if [[ -d ~/branches/"$branch" ]]; then
    cd ~/branches/"${branch}"
  else
    cd ~/equalizer.git
  fi
}

function update_branch() {
  (
    # set -o errexit # Can't do this inside a function
    set -o nounset
    set -o pipefail
    printf "=== Updating the branch...\n"
    git fetch --all || exit "$?"
    git pull --rebase || exit "$?"
    git rebase --interactive develop_front || exit "$?"
    printf "=== Updating the dependencies...\n"
    install_equalizer_deps
  )
}

function install_equalizer_deps() {
  (
    # set -o errexit # Can't do this inside a function
    set -o nounset
    set -o pipefail
    printf "Installing Ruby dependencies...\n"
    bundle install || exit "$?"
    printf "Installing Javascript dependencies...\n"
    printf "Installing in top level...\n"
    yarn install || exit "$?"
    printf "Installing in widget...\n"
    cd widget || exit "$?"
    yarn install || exit "$?"
    yarn build || exit "$?"
    cd .. || exit "$?"
    printf "Installing in front...\n"
    cd front || exit "$?"
    yarn install
  )
}

function delete_branch() {
}
