{
  flake-file.inputs = {
    # Pins nix-direnv to 3.1.0 until https://github.com/nix-community/nix-direnv/pull/790
    # is resolved, as newer versions reload the environment constantly.
    nixpkgsNixDirenv.url = "github:nixos/nixpkgs/e6f23dc08d3624daab7094b701aa3954923c6bbb";
  };
}
