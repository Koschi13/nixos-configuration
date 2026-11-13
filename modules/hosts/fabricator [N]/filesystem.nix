{
  flake.modules.nixos.fabricator = {
    fileSystems = {
      "/" = {
        device = "/dev/mapper/MAIN-NIXROOT";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-uuid/501A-FA1C";
        fsType = "vfat";
        options = ["fmask=0022" "dmask=0022"];
      };
    };

    swapDevices = [{device = "/dev/mapper/MAIN-NIXSWAP";}];
  };
}
