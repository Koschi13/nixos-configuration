#!/usr/bin/env bash

set -euo pipefail

# The checkout this script lives in, so worktrees build their own branch
pushd "$(dirname "$(readlink -f "$0")")/.." || exit

nix flake update

popd || exit
