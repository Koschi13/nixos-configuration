let
  stateVersion = import ./_stateVersion.nix;
in {
  flake-file.inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-${stateVersion.nixOs}";
    nixpkgs-stable-small.url = "github:nixos/nixpkgs/nixos-${stateVersion.nixOs}-small";
    # The channel tarball doesn't depend on GitHub and its rate-limited API, is
    # about a third smaller (xz instead of gzip) and ships extra release
    # metadata, like the programs.sqlite database of command-not-found.
    # See https://discourse.nixos.org/t/use-channels-as-flake-inputs/75261
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.xz";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
  };
}
