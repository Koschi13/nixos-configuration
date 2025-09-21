#!/usr/bin/env bash

set -euo pipefail

USER_SCRIPT=""
if [[ "$HOSTNAME" == "epsilon" ]]; then
  USER_SCRIPT="./scripts/apply-users-hiq.sh"
elif [[ "$HOSTNAME" == "alpha" ]]; then
  USER_SCRIPT="./scripts/apply-users-max.sh"
fi

if [[ "$USER_SCRIPT" == "" ]]; then
  echo "Failed to determin user!"
  exit 1
fi

pushd ~/.dotfiles || exit

./scripts/apply-system.sh &&
  eval $USER_SCRIPT

popd || exit
