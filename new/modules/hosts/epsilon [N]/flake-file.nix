{
  flake-file.inputs = {
    # Hardware profiles, see `hardware.nix`
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Work tooling of HiQ, only reachable from the work network
    htt.url = "git+ssh://git@gitea.scandio.com:8000/tkumschier/htt.git?ref=smaller-improvements&rev=96659bcf6c0d8ac1b02560eb41639aae95914796";
  };
}
