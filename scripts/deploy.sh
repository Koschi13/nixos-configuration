#!/usr/bin/env bash
# Builds the configuration of a host locally and activates it there over SSH,
# e.g. `deploy.sh fabricator`. Activates as root, which the `ssh` aspect only
# allows from the trusted networks and with the key of the YubiKey.

set -euo pipefail

host="${1:?usage: deploy.sh <host>}"

# The checkout this script lives in, so worktrees build their own branch
pushd "$(dirname "$(readlink -f "$0")")/.." || exit

nh os switch . --hostname "$host" --target-host "root@$host.lan" --elevation-strategy none

# The packages of the new system, for the CVE overview. The deploy is done
# either way.
if ! ./scripts/sbom-upload.sh "$host"; then
  cat >&2 <<EOF
warning: the package inventory of $host was not uploaded, see the error above.
The system itself is switched. Retry once fabricator is reachable:
  ./scripts/sbom-upload.sh $host
EOF
fi

popd || exit
