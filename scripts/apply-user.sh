#!/bin/sh
pushd ~/.dotfiles
home-manager switch -f ./users/$USER/home.nix
popd
