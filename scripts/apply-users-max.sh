#!/usr/bin/env sh

if [[ $HOST == "epsilon" ]]; then
  echo "This is your work laptop you fool!"
  exit 1
fi

pushd ~/.dotfiles
home-manager switch --flake .#max
popd
