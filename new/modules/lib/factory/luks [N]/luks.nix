# Required settings for luks to work
{self, ...}: {
  config.flake.factory.luks = host: uuid: {
    nixos."${host}" = {
      boot = {
        loader = {
          efi.canTouchEfiVariables = true;

          grub = {
            enable = true;
            device = "nodev";
            efiSupport = true;
          };
        };
        initrd = {
          luks.devices.luksroot = {
            name = "luksroot";
            device = "/dev/disk/by-uuid/${uuid}";
            preLVM = true;
            # TODO: This one might not be needed
            # allowDiscards = true;
          };
        };
      };
    };
  };
}
