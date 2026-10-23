{inputs, ...}: {
  flake.modules.nixos.epsilon = {
    # Enables microcode updates, the Intel GPU drivers, thermald, TLP and
    # fstrim for this laptop
    imports = [inputs.nixos-hardware.nixosModules.tuxedo-infinitybook-pro14-gen7];

    dotfiles.cpuVendor = "intel";

    hardware = {
      acpilight.enable = true;

      tuxedo-rs = {
        enable = true;
        tailor-gui.enable = true;
      };
    };
  };
}
