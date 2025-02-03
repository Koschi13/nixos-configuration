#!/usr/bin/env sh
USER_SCRIPT=""
if [[ "$HOSTNAME" == "epsilon" ]]; then
  USER_SCRIPT="./scripts/apply-users-scandio.sh"
elif [[ "$HOSTNAME" == "alpha" ]]; then
  USER_SCRIPT="./scripts/apply-users-max.sh"
fi

if [[ "$USER_SCRIPT" == "" ]]; then
  echo "Failed to determin user!"
  exit 1
fi

pushd ~/.dotfiles

sudo nixos-rebuild switch --flake .# \
  && eval $USER_SCRIPT

popd
