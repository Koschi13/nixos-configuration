{
  flake.modules.nixos.fabricator = {
    dotfiles.cpuVendor = "intel";

    # Firmware comes from the `firmware` aspect of `system-default`
    hardware.cpu.intel.updateMicrocode = true;
  };
}
