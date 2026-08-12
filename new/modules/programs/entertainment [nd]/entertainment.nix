{...}: {
  flake.modules.homeManager.entertainment = {pkgs, ...}: {
    home.packages = with pkgs; [spotify easyeffects];
  };
}
