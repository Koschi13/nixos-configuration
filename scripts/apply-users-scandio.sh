#!/usr/bin/env sh

if [[ "$HOSTNAME" != "epsilon" ]]; then
  echo "This is NOT your work laptop you fool!"
  exit 1
fi

pushd ~/.dotfiles
home-manager switch --flake .#scandio
popd
