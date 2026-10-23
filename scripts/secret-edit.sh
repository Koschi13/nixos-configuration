#!/usr/bin/env bash
# Runs the `agenix` CLI in secrets/ with the admin age key, e.g.
#   secret-edit.sh -e git-hiq.age   edit (or create) a secret
#   secret-edit.sh -r               re-encrypt all after changing the keys
#
# The admin key is wrapped with the GPG key of the YubiKey. It and the
# plaintext agenix hands to $EDITOR only ever live in $XDG_RUNTIME_DIR (tmpfs).

set -euo pipefail

root="$(git -C "$(dirname "$0")" rev-parse --show-toplevel)"
runtime="${XDG_RUNTIME_DIR:?XDG_RUNTIME_DIR must be set (tmpfs)}"

workdir="$(mktemp -d "$runtime/secret-edit.XXXXXX")"
trap 'rm -rf "$workdir"' EXIT
chmod 700 "$workdir"

key="$workdir/admin.key"
(umask 077 && gpg --quiet --decrypt -o "$key" "$root/keys/admin.key.gpg")

cd "$root/secrets"
AGENIX_RULES="$root/secrets/agenix-rules.nix" TMPDIR="$workdir" nix run --inputs-from "$root" agenix -- "$@" -i "$key"
