{
  flake.modules.homeManager.messengers = {pkgs, ...}: {
    home.packages = with pkgs; [element-desktop signal-desktop telegram-desktop];
  };
}
