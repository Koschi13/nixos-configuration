{
  flake.modules.nixos.epsilon = {
    nixpkgs.hostPlatform = "x86_64-linux";

    hardware = {
      # TODO@comp: This was false
      cpu.intel.updateMicrocode = true;

      acpilight.enable = true;

      tuxedo-rs = {
        enable = true;
        tailor-gui.enable = true;
      };
    };
  };
}
