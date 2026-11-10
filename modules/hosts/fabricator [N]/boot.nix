{
  flake.modules.nixos.fabricator = {
    boot = {
      loader = {
        efi.canTouchEfiVariables = true;

        systemd-boot = {
          enable = true;
          configurationLimit = 10;
        };
      };

      initrd = {
        availableKernelModules = [
          "xhci_pci"
          "ahci"
          "nvme"
          "usbhid"
          "usb_storage"
          "sd_mod"
        ];
        # The system disk is an LVM volume group
        kernelModules = ["dm-snapshot"];
      };

      kernelModules = ["kvm-intel"];
    };
  };
}
