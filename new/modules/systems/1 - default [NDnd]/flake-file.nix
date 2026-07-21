{...}: let
  releaseChannel = "26.05";
in {
  flake-file.inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-${releaseChannel}";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-${releaseChannel}-small";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
  };
}
