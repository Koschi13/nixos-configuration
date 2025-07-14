#!/usr/bin/env bash

if [[ "$HOSTNAME" == "epsilon" ]]; then
  echo "This is your work laptop you fool!"
  exit 1
fi

pushd ~/.dotfiles || exit
home-manager switch --flake .#max
popd || exit
