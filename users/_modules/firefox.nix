{ config, pkgs, firefox-addons, ... }:

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
	# This is fucked up, unfree packages do not work her!
	# onepassword-password-manager
      ];
    };
  };

  home.sessionVariables = {
    MOZ_ENABLE_WAYLAND = 1;
    DEFAULT_BROWSER = "${pkgs.firefox}/bin/firefox";
  };
}
