# DO-NOT-EDIT. This file was auto-generated using github:vic/flake-file.
# Use `nix run .#write-flake` to regenerate it.
{
  outputs = inputs: inputs.flake-parts.lib.mkFlake {inherit inputs;} (inputs.import-tree ./modules);

  inputs = {
    catppuccinAlacritty = {
      url = "github:catppuccin/alacritty";
      flake = false;
    };
    catppuccinGhostty = {
      url = "github:catppuccin/ghostty";
      flake = false;
    };
    catppuccinI3 = {
      url = "github:catppuccin/i3";
      flake = false;
    };
    catppuccinStarship = {
      url = "github:catppuccin/starship";
      flake = false;
    };
    denisidoroCheats = {
      url = "github:denisidoro/cheats";
      flake = false;
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-file.url = "github:vic/flake-file";
    flake-parts.url = "github:hercules-ci/flake-parts";
    git-crypt-secrets = {
      url = "path:../.secrets";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:vic/import-tree";
    mattpocockSkills = {
      url = "github:mattpocock/skills";
      flake = false;
    };
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-stable-small.url = "github:nixos/nixpkgs/nixos-26.05-small";
    nixpkgsNixDirenv.url = "github:nixos/nixpkgs/e6f23dc08d3624daab7094b701aa3954923c6bbb";
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
