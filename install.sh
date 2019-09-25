#!/bin/bash

script="$( realpath -e "${BASH_SOURCE[0]}" )"
dir="$( dirname "$script" )"
hostdir="$dir"/per-host/"$(hostname)"

if [[ ! -d "$hostdir" ]]; then
  echo "Copying data from template..."
  cp -T -a "$dir"/per-host/template "$hostdir"
fi

if [[ ! -z "$2" ]]; then
  relpath=$( realpath --no-symlinks --relative-to "$hostdir" "$2" )
fi

if [[ -z "$1" ]]; then
  find "$hostdir" \
    \( \
     \( -type f -or -type l \) \
     -execdir "$script" link '{}' \; \
    \) -or \( \
     -type d \
     -not -samefile "$hostdir" \
     -execdir "$script" mkdir '{}' \; \
     \)
  chmod 700 ~/.ssh
elif [[ "$1" == "link" ]]; then
  ln --symbolic "$hostdir/$relpath" ~/"$relpath"
elif [[ "$1" == "mkdir" ]]; then
  mkdir -p ~/"$relpath"
else
  echo "unknown command $1"
fi