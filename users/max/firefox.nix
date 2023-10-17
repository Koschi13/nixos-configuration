{ config, pkgs, firefox-addons, ...}:

{
  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;
      extensions = with firefox-addons.packages.${pkgs.system}; [
        ublock-origin
        bitwarden
        tridactyl
        multi-account-containers
      ];
    };
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
  };
}
