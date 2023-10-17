#!/bin/sh
pushd ~/.dotfiles
home-manager --flake .#max
popd
