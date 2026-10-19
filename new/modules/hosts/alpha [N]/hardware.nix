{
  flake.modules.nixos.alpha = {
    dotfiles.cpuVendor = "amd";

    hardware = {
      # TODO@comp: This was false
      cpu.amd.updateMicrocode = true;

      # 32-bit applications like Wine or older games need these drivers
      graphics.enable32Bit = true;
    };
  };
}
