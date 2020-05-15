#!/bin/bash
. ~/.bash_aliases-common

if [[ -f ~/.bash_tools ]]; then
  . ~/.bash_tools
fi

auto_tmux

function wovn_start() {
  (
    # set -o errexit # Can't do this inside a function
    set -o nounset
    set -o pipefail
    branch=${1:?}
    branch=${branch#feature/}
    tmux -2 new-window -t "Main Screen" -n "$branch" -c ~/equalizer -e BRANCH_NAME="$branch" 'bash -ic "_start_branch \"\$BRANCH_NAME\"; exec bash"'
  )
}

function _start_branch() {
  branch=${1:?}
  branch=${branch#feature/}
  (
    # set -o errexit # Can't do this inside a function
    set -o nounset
    set -o pipefail
    if [[ ! -d ~/equalizer/"$branch" ]]; then
      printf "=== Setting up a branch named ${branch}...\n"
      cd ~/equalizer/master || exit "$?"
      wovn_pull
      if git show-ref --verify --quiet "refs/heads/feature/${branch}"; then
        # Local branch exists, but the directory doesn't
        printf "=== Checking out the local branch named feature/${branch} in a new working tree at ~/equalizer/${branch}...\n"
      elif git show-ref --verify --quiet "refs/remote/origin/feature/${branch}"; then
        # Remote branch exists, but no local branch or directory
        printf "=== Checking out the remote branch named feature/${branch} in a new working tree at ~/equalizer/${branch}...\n"
        git branch --track "feature/${branch}" "origin/feature/${branch}" || exit "$?"
      else
        # Neither local nor remote branch exists, so create one.
        printf "=== Creating a local and remote branch pair named feature/${branch} and checking it out in a new working tree at ~/equalizer/${branch}...\n"
        git branch --no-track "feature/${branch}" "origin/develop_front" || exit "$?"
        git push --set-upstream origin "feature/${branch}"
      fi
      git worktree add ../"${branch}" "feature/${branch}" || exit "$?"
    else
      printf "=== Accessing an existing branch named ${branch}...\n"
    fi
    cd ~/equalizer/"${branch}" || exit "$?"
    wovn_update || exit "$?"
    printf "\a=== Your branch ${branch} is ready!\n"
  )
  if [[ -d ~/equalizer/"$branch" ]]; then
    cd ~/equalizer/"${branch}"
  else
    cd ~/equalizer/
  fi
}

function get_current_branch_name() {
  git symbolic-ref --quiet --short HEAD
}

function get_remote_branch_name() {
  git rev-parse --abbrev-ref --symbolic-full-name '@{u}'
}

function wovn_pull() {
  (
    printf "=== Retrieving the latest data from the repository...\n"
    cd ~/equalizer/master || exit "$?"
    git pull || exit "$?"
    cd ~/equalizer/develop || exit "$?"
    git pull || exit "$?"
    cd ~/equalizer/develop_front || exit "$?"
    git pull || exit "$?"
  )
}

function wovn_update() {
  (
    cd "$(git rev-parse --show-toplevel)"
    # set -o errexit # Can't do this inside a function
    set -o nounset
    set -o pipefail
    wovn_pull
    printf "=== Updating the branch...\n"
    if get_remote_branch_name >&/dev/null; then
      git pull --rebase || exit "$?"
    fi
    git rebase develop_front || exit "$?"
    printf "=== Checking dependencies...\n"
    wovn_install
  )
}

function wovn_install() {
  (
    cd "$(git rev-parse --show-toplevel)"
    # set -o errexit # Can't do this inside a function
    set -o nounset
    set -o pipefail
    if ! bundle check >&/dev/null; then
      printf "=== Installing Ruby dependencies...\n"
      bundle install || exit "$?"
    fi
    if ! yarn install --offline --check-files --no-progress --ignore-optional --non-interactive --silent >&/dev/null; then
      printf "=== Installing Javascript dependencies in top level...\n"
      yarn install || exit "$?"
    fi
    cd widget || exit "$?"
    if ! yarn install --offline --check-files --no-progress --ignore-optional --non-interactive --silent >&/dev/null; then
      printf "=== Installing Javascript dependencies in widget...\n"
      yarn install || exit "$?"
      yarn build || exit "$?"
    fi
    cd .. || exit "$?"
    cd front || exit "$?"
    if ! yarn install --offline --check-files --no-progress --ignore-optional --non-interactive --silent >&/dev/null; then
      printf "=== Installing Javascript dependencies in front...\n"
      yarn install
    fi
  )
}

function wovn_delete() {
  (
    # set -o errexit # Can't do this inside a function
    set -o nounset
    set -o pipefail
    branch=${1:+feature/$1}
    branch=${branch:-$(get_current_branch_name)} || exit "$?"
    cd ~/equalizer/master
    worktree="$(git worktree list --porcelain | grep -B2 ${branch} | cut -d' ' -f2 | head -n1)" || exit "$?"
    git worktree remove "$worktree" || exit "$?"
    git branch -d "$branch" || exit "$?"
  ); local lastexit="$?"
  if [[ ! -d "$PWD" ]]; then
    cd ~/equalizer/master
  fi
  return $lastexit
}
function _list_feature_branches() {
  git --git-dir ~/equalizer/master/.git for-each-ref --format '%(refname:short)' refs/heads/ \
    | grep -vF $'develop\ndevelop_front\nmaster' \
    | sed 's#^feature/##'
}

function _branch_completions() {
  if [[ $COMP_CWORD -ne 1 ]]; then
    return
  fi
  COMPREPLY+=($(compgen -W "$(_list_feature_branches)" "${COMP_WORDS[1]}"))
}

complete -F _branch_completions wovn_start
complete -F _branch_completions wovn_delete
