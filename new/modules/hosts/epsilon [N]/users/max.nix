{self, ...}: let
  # Work tooling of HiQ, only reachable from the work network. Fetched with
  # `getFlake` instead of a flake input, so that `nix flake update` does not
  # need access to it on every host. The pinned `rev` keeps it pure.
  htt = builtins.getFlake "git+ssh://git@gitea.scandio.com:8000/tkumschier/htt.git?ref=smaller-improvements&rev=96659bcf6c0d8ac1b02560eb41639aae95914796";
in {
  flake.modules.nixos.epsilon = let
    inherit (self) modules;
    username = "max";
  in {
    imports = [
      modules.nixos.${username} # -> imports users/max which sets up HomeManager
    ];

    # The work setup of max at HiQ
    home-manager.users.${username} = {pkgs, ...}: {
      imports = with modules.homeManager; [
        ssh
        tmux
        vw-ssm
        neovim-copilot
      ];

      programs.ssh.settings = {
        "alpha.lan" = {
          hostname = "alpha.lan";
          user = "max";
          identityFile = "~/.ssh/yubikey.pub";
        };
      };

      home.packages = with pkgs; [
        # tools
        zip
        unzip
        bruno # postman alternative

        # coding
        opencode
        opencode-desktop

        openvpn # Workaround for nm-openvpn not working

        # other
        cifs-utils
        nfs-utils

        # work
        slack
        google-chrome
        dive
        obsidian
        docker-compose

        # company stuff
        htt.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
