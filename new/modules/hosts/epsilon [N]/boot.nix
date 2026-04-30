{
  flake.modules.nixos.epsilon = {config, ...}: {
    boot = {
      loader = {
        efi.canTouchEfiVariables = true;

        grub = {
          enable = true;
          efiSupport = true;
          # Required as we have a luks encrypted system
          device = "nodev";
          configurationLimit = 10;
        };
      };

      initrd = {
        # TODO: revisit, to see what is actually needed and not already automatically loaded
        availableKernelModules = [
          "xhci_pci"
          "thunderbolt"
          "nvme"
          "usb_storage"
          "sd_mod"
        ];
        kernelModules = ["dm-snapshot"];
      };

      kernelModules = [
        "kvm-intel"
        "v4l2loopback"
      ];

      extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
      # Enable OBS virtual camera
      extraModprobeConfig = ''
        options v4l2loopback devices=1 video_nr=1 card_label="OBS Cam" exclusive_caps=1
      '';
      # Needed for onboard audio, see:
      # https://discourse.nixos.org/t/realtek-audio-sound-card-not-recognized-by-pipewire/36637
      kernelParams = ["snd-intel-dspcfg.dsp_driver=1"];
    };
  };
}
