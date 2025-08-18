#!/usr/bin/env bash

if [[ "$HOSTNAME" != "epsilon" ]]; then
  echo "This is NOT your work laptop you fool!"
  exit 1
fi

pushd ~/.dotfiles || exit
# home-manager switch --flake .#hiq
nh home switch -c hiq .
popd || exit
