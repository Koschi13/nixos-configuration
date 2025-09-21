#!/usr/bin/env bash

set -euo pipefail

pushd ~/.dotfiles || exit
#sudo nixos-rebuild switch --flake .#
nh os switch .#
popd || exit
