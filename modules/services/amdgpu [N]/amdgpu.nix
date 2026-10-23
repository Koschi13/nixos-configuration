{
  flake.modules = {
    nixos.amdgpu = {
      # GPU control daemon and GUI
      services.lact.enable = true;
      # Unlocks clock and voltage control, which lact needs for overclocking
      hardware.amdgpu.overdrive.enable = true;
    };
  };
}
