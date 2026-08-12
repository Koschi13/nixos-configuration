# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);

  inputs = {
    agenix = {
      url = "github:ryantm/agenix";
      inputs = {
        home-manager.follows = "home-manager";
        nixpkgs.follows = "nixpkgs";
      };
    };
    catppuccinI3 = {
      url = "github:catppuccin/i3";
      flake = false;
    };
    catppuccinStarship = {
      url = "github:catppuccin/starship";
      flake = false;
    };
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-stable-small.url = "github:nixos/nixpkgs/nixos-26.05-small";
    secrets = {
      url = "path:./secrets";
      flake = false;
    };
    zsh-alias-finder = {
      url = "github:akash329d/zsh-alias-finder";
      flake = false;
    };
    zsh-calc = {
      url = "github:arzzen/calc.plugin.zsh";
      flake = false;
    };
    zsh-enhancd = {
      url = "github:babarot/enhancd";
      flake = false;
    };
  };
}
