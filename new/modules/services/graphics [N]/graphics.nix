{...}: {
  flake.modules.nixos.bluetooth = {
    hardware.graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
