{
  pkgs,
  firefox-addons,
  config,
  ...
}: {
  programs.firefox = {
    enable = true;
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    profiles.default = {
      id = 0;
      name = "Default";
      isDefault = true;
      extensions.packages = with firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
        ublock-origin
        bitwarden
        tridactyl
        multi-account-containers
        # This is fucked up, unfree packages do not work her!
        # onepassword-password-manager
      ];
    };
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
    BROWSER = "firefox";
  };
}
