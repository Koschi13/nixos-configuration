{
  self,
  inputs,
  ...
}: {
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
        inputs.htt.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
    };
  };
}
