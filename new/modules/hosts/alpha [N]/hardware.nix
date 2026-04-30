{
  flake.modules.nixos.alpha = {
    nixpkgs.hostPlatform = "x86_64-linux";

    hardware = {
      cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      # Default graphic acceleration
      graphics = {
        enable = true;
        enable32Bit = true;
      };
    };
  };
}
