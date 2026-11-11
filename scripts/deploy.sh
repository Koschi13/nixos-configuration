#!/usr/bin/env bash
# Builds the configuration of a host locally and activates it there over SSH,
# e.g. `deploy.sh fabricator`. Activates as root, which the `ssh` aspect only
# allows from the trusted networks and with the key of the YubiKey.

set -euo pipefail

host="${1:?usage: deploy.sh <host>}"

# The checkout this script lives in, so worktrees build their own branch
pushd "$(dirname "$(readlink -f "$0")")/.." || exit

nh os switch . --hostname "$host" --target-host "root@$host.lan" --elevation-strategy none

popd || exit
