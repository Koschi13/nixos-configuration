{inputs, ...}: {
  # TODO: create the flake.nix yourself -- aligns with TODO.md
  flake-file.inputs = {
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  # Enables Home-Manager integration for flake-parts
  # https://flake.parts/options/home-manager.html
  imports = [inputs.home-manager.flakeModules.home-manager];
}
