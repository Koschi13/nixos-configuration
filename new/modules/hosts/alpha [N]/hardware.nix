{
  flake.modules.nixos.alpha = {
    nixpkgs.hostPlatform = "x86_64-linux";

    hardware = {
      # TODO@comp: This was false
      cpu.amd.updateMicrocode = true;
    };
  };
}
