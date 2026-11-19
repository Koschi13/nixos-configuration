#!/usr/bin/env bash

set -euo pipefail

# The checkout this script lives in, so worktrees build their own branch
pushd "$(dirname "$(readlink -f "$0")")/.." || exit

#sudo nixos-rebuild switch --flake .#
nh os switch .#

# The packages of the new system, for the CVE overview. The switch is done
# either way.
if ! ./scripts/sbom-upload.sh; then
  cat >&2 <<EOF
warning: the package inventory of $(hostname) was not uploaded, see the error above.
The system itself is switched. Retry once fabricator is reachable:
  ./scripts/sbom-upload.sh
EOF
fi

popd || exit
