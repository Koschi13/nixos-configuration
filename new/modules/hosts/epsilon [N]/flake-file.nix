{
  flake-file.inputs = {
    # Hardware profiles, see `hardware.nix`
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
