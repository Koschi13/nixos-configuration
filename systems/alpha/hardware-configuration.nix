{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot = {
    loader = {
      grub = {
        enable = true;
        useOSProber = true;
        efiSupport = true;
        default = "saved";
        device = "nodev";
        configurationLimit = 10;
      };

      efi = {
        canTouchEfiVariables = true;
      };
    };

    initrd = {
      availableKernelModules = [
        "nvme"
        "xhci_pci"
        "ahci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = ["dm-snapshot"];
      luks.devices.luksroot = {
        name = "luksroot";
        device = "/dev/disk/by-uuid/8e424358-602c-490d-9a00-ad3d00108f32";
        preLVM = true;
        allowDiscards = true;
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXROOT";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/disk/by-label/NIXBOOT";
      fsType = "vfat";
    };
  };

  swapDevices = [{device = "/dev/disk/by-label/NIXSWAP";}];

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };

    # Default graphic acceleration
    graphics = {
      enable = true;

      enable32Bit = true;
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
