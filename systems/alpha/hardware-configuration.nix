{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

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
      kernelModules = [ "dm-snapshot" ];
      luks.devices.luksroot = {
        name = "luksroot";
        device = "/dev/disk/by-uuid/8e424358-602c-490d-9a00-ad3d00108f32";
        preLVM = true;
        allowDiscards = true;
      };
    };

    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
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

  swapDevices = [ { device = "/dev/disk/by-label/NIXSWAP"; } ];

  # Enable nvidia drivers
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware = {
    cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # Default graphic acceleration
    graphics = {
      enable = true;
      enable32Bit = true;
    };


    # NvidiaConfig (nvidia)
    nvidia = {
      modesetting.enable = true;
      open = false;

      nvidiaSettings = true;
      package = config.boot.kernelPackages.nvidiaPackages.latest;

      prime = {
		    # Make sure to use the correct Bus ID values for your system!
		    nvidiaBusId = "PCI:10:0:0";
        amdgpuBusId = "PCI:5:0:0";

        offload = {
          enable = true;
          enableOffloadCmd = true;
        };
      };
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
