#!/bin/bash

if [[ ! -d ~/.common-configs ]]; then
  git clone https://github.com/programmablereya/common-configs.git ~/.common-configs
  cd ~/.common-configs
else
  cd ~/.common-configs
  git pull
fi

source ./bash_aliases.sh

./install.sh

if [[ ! -f ~/.ssh/id_ed25519.pub ]]; then
  ssh-keygen
   
  ssh-authorize-key ~/.ssh/id_ed25519.pub

  echo "*** New keypair generated. Please add the new public key to github/bitbucket authorized keys:"
  cat ~/.ssh/id_ed25519.pub
  read -p "Press ENTER when done."
fi

ORIGIN=$(git ls-remote --get-url origin)
if [[ "$ORIGIN" != 'git@github.com:programmablereya/common-configs.git' ]]; then
  git remote set-url origin git@github.com:programmablereya/common-configs.git

  sync_git_only
fi
