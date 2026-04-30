{
  flake.modules.homeManager.office = {pkgs, ...}: {
    home.packages = with pkgs; [libreoffice-qt6-fresh];
  };
}
