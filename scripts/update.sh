#!/usr/bin/env bash

set -euo pipefail

pushd ~/.dotfiles || exit

nix flake update

popd || exit
