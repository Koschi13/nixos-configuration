{
  flake.modules.nixos.alpha = {
    boot = {
      loader = {
        efi.canTouchEfiVariables = true;

        grub = {
          enable = true;
          useOSProber = true;
          efiSupport = true;
          default = "saved";
          # Required as we have a luks encrypted system
          device = "nodev";
          configurationLimit = 10;
        };
      };

      initrd = {
        # TODO: revisit, to see what is actually needed and not already automatically loaded
        availableKernelModules = [
          "nvme"
          "xhci_pci"
          "ahci"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        kernelModules = ["dm-snapshot"];
      };
    };
  };
}
