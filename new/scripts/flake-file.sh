#!/usr/bin/env bash

set -euo pipefail

nix run .#write-flake
