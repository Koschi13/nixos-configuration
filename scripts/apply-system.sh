#!/usr/bin/env bash

pushd ~/.dotfiles || exit
#sudo nixos-rebuild switch --flake .#
nh os switch .#
popd || exit
