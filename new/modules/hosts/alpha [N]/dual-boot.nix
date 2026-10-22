{
  # alpha dual-boots Windows, which keeps the hardware clock in local time
  flake.modules.nixos.alpha = {
    time.hardwareClockInLocalTime = true;
  };
}
