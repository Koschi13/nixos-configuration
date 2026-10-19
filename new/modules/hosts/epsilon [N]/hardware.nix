{
  flake.modules.nixos.epsilon = {
    dotfiles.cpuVendor = "intel";

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
