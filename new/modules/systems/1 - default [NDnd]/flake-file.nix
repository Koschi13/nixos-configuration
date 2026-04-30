let
  stateVersion = import ./_stateVersion.nix;
in {
  flake-file.inputs = {
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-${stateVersion.nixOs}";
    nixpkgs-stable-small.url = "github:nixos/nixpkgs/nixos-${stateVersion.nixOs}-small";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
  };
}
