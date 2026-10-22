{
  flake-file.inputs = {
    # Weekly prebuilt nix-index database, no local indexing needed
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
