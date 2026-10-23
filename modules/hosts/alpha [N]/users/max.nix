{self, ...}: {
  flake.modules.nixos.alpha = let
    inherit (self) modules factory;
    username = "max";
  in {
    imports = [
      modules.nixos.${username} # -> imports users/max which sets up HomeManager

      (factory.mount-homeserver {inherit username;})
    ];

    # The private setup of max
    home-manager.users.${username} = {pkgs, ...}: {
      imports = with modules.homeManager; [
        mistral-vibe
      ];

      home.packages = with pkgs; [
        nvtopPackages.full
        android-tools
        android-studio
        proton-vpn
        discord
        telegram-desktop
        pdfsam-basic
        vlc
        # TODO: Back to unstable once pyopenjtalk-plus' tests pass again
        stable.calibre
        mp3cat
        puddletag
      ];
    };
  };
}
