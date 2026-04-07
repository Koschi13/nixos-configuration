{...}: {
  programs.gamemode.enable = true;

  boot.kernelModules = ["ntsync"];
}
