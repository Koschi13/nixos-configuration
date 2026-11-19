#!/usr/bin/env bash
# Uploads the packages of a host to the `cve-scan` service, which lists their
# CVEs on http://cve.lan and in Glance, e.g. `sbom-upload.sh fabricator`.
# Without an argument: the packages of this host. `apply.sh` and `deploy.sh`
# run it after every switch, run it by hand if they couldn't reach the server.
#
# Creates a CycloneDX SBOM of the system with sbomnix, reduced to what the scan
# needs, and hands it to `cve-scan-import` on the server as root, like a
# deploy: only from the trusted networks and with the key of the YubiKey.

set -euo pipefail

# Overridable to test against another server
server="${CVE_SCAN_SERVER:-root@fabricator.lan}"

# The checkout this script lives in, so worktrees use their own branch
root="$(dirname "$(readlink -f "$0")")/.."
localHost="$(hostname)"
host="${1:-$localHost}"

fail() {
  echo "error: $*" >&2
  exit 1
}

workDirectory="$(mktemp -d "${XDG_RUNTIME_DIR:-/tmp}/sbom-upload.XXXXXX")"
# One connection for the check and the upload, so the YubiKey is touched once
# and right away instead of after the SBOM is created
sshOptions=(
  -o ConnectTimeout=5
  -o ControlMaster=auto
  -o "ControlPath=$workDirectory/ssh"
  -o ControlPersist=15m
)
cleanup() {
  ssh "${sshOptions[@]}" -O exit "$server" 2>/dev/null || true
  rm -rf "$workDirectory"
}
trap cleanup EXIT

# Before the SBOM, which takes minutes
echo ">>> Touch the YubiKey to upload the packages of $host for the CVE overview <<<"
ssh "${sshOptions[@]}" "$server" true || fail "can't reach $server"

if [ "$host" = "$localHost" ]; then
  # What is running, whatever the checkout contains by now
  system="$(readlink -f /run/current-system)"
else
  system="$(nix eval --raw "$root#nixosConfigurations.$host.config.system.build.toplevel.outPath")"
  [ -e "$system" ] || fail "the system of $host isn't built on this host, deploy it first"
fi

echo "Collecting the packages of $host ($(basename "$system")), this takes a few minutes"
# sbomnix writes more than the requested file into the working directory
(
  cd "$workDirectory"
  # From unstable: the release of stable finds no version for packages
  # substituted from the binary cache
  nix run --inputs-from "$root" nixpkgs#sbomnix -- "$system" --cdx sbom.cdx.json
)

# No store paths and no dependency graph, the scan only reads these fields
jq --compact-output '{
  bomFormat,
  specVersion,
  version,
  metadata: {
    timestamp: .metadata.timestamp,
    component: (.metadata.component | {type, name, version})
  },
  components: [.components[] | {type, name, version, purl, cpe}]
}' "$workDirectory/sbom.cdx.json" | gzip -9 >"$workDirectory/upload.cdx.json.gz"

ssh "${sshOptions[@]}" "$server" cve-scan-import "$host" <"$workDirectory/upload.cdx.json.gz" ||
  fail "the upload to $server failed"
