#!/usr/bin/env sh
pushd ~/.dotfiles
sudo nixos-rebuild switch --flake .#
popd
