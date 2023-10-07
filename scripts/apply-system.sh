#!/bin/sh
pushd ~/.dotfiles
sudo nixos-rebuild switch -I nixos-config=./systems/$HOSTNAME/configuration.nix
popd
