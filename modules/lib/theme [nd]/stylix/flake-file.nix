{
  flake-file.inputs = {
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.tinted-schemes.follows = "tinted-schemes";
      inputs.flake-parts.follows = "flake-parts";
    };
    # The base16 schemes every theme picks its palette from
    tinted-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
  };
}
