{pkgs, ...}: {
  programs.gamemode.enable = true;

  boot.kernelModules = ["ntsync"];
  environment.systemPackages = with pkgs; [mesa];
}
