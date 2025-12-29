#!/usr/bin/env bash
# Exports the GitHub auth token, so that Nix can use it when querying against
# the GitHub API. This resolves rate limiting and authentication issues for
# private repositories.
#
# Example '.envrc':
#   source nix-github-login
#   nix use flake 'github:Koschi13/nix-templates?dir=languages/python311'
#
# It's important to `source` the script, as otherwise the exports are not
# exposed to your shell. This is because each binScript is executed in it's
# own process instead of the current one

if [ -z "$GITHUB_TOKEN" ]; then
  nix run nixpkgs#gh auth status || nix run nixpkgs#gh auth login
  GITHUB_TOKEN="$(nix run nixpkgs#gh auth token)"
  export GITHUB_TOKEN
fi

NIX_CONFIG="access-tokens = github.com=$GITHUB_TOKEN"
export NIX_CONFIG
