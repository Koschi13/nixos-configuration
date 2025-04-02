{
  config,
  ...
}:{
  hardware.nvidia = {
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
}
