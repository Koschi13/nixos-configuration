# Temporary workaround: pgadmin4 9.18 fails its reverse-engineered SQL tests on
# nixpkgs-unstable since the PostgreSQL packaging switched to upstream tags
# (nixpkgs 586603): foreign table columns now get an extra `SET (pg_attver=...)`.
# Hydra fails too: https://hydra.nixos.org/build/353066319. Delete this file once
# `nix build nixpkgs#pgadmin4` (or Hydra's pgadmin4 job) succeeds again.
{
  flake.modules.nixos.fabricator = {pkgs, ...}: {
    services.pgadmin.package = pkgs.stable.pgadmin4;
  };
}
