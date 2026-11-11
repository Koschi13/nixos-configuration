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
    home-manager.users.${username} = {
      lib,
      pkgs,
      ...
    }: {
      imports = with modules.homeManager; [
        ssh
      ];

      programs.ssh.settings = let
        gnupgSockets = "/run/user/1000/gnupg";
        servers = ["fabricator"];
      in
        lib.mergeAttrsList (map (server: {
            # Interactive work as max, with the YubiKey of this host available
            # on the server. The shell sets `SSH_AUTH_SOCK` to the path of the
            # gpg-agent, so `ForwardAgent` would have no effect.
            "${server} ${server}.lan" = {
              hostname = "${server}.lan";
              user = "max";
              identityFile = "~/.ssh/yubikey.pub";
              RemoteForward = [
                {
                  bind.address = "${gnupgSockets}/S.gpg-agent";
                  host.address = "${gnupgSockets}/S.gpg-agent.extra";
                }
                {
                  bind.address = "${gnupgSockets}/S.gpg-agent.ssh";
                  host.address = "${gnupgSockets}/S.gpg-agent.ssh";
                }
              ];
            };
            # `root@<server>`, used by deploys: no forwards, as the newest
            # forwarding session would take over the sockets of the open ones
            "Match originalhost ${server},${server}.lan user root" = {
              ClearAllForwardings = "yes";
            };
          })
          servers);

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
        teamspeak6-client
      ];
    };
  };
}
