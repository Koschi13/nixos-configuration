#!/usr/bin/env sh
if [ $HOST -ne "epsilon"]; then
    exit 1
fi
pushd ~/.dotfiles
home-manager switch --flake .#scandio
popd
