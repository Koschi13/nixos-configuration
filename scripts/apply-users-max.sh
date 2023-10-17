#!/usr/bin/env sh
pushd ~/.dotfiles
home-manager switch --flake .#max
popd
