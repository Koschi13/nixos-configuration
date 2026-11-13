#!/usr/bin/env bash

set -euo pipefail

# The checkout this script lives in, so worktrees build their own branch
pushd "$(dirname "$(readlink -f "$0")")/.." || exit

#sudo nixos-rebuild switch --flake .#
nh os switch .#

popd || exit
