{self, ...}: {
  # The work setup of max at HiQ, used as standalone Home-Manager
  # configuration on epsilon.
  flake.modules.homeManager.hiq = {pkgs, ...}: let
    htt = builtins.getFlake "git+ssh://git@gitea.scandio.com:8000/tkumschier/htt.git?ref=smaller-improvements&rev=96659bcf6c0d8ac1b02560eb41639aae95914796";
  in {
    imports = with self.modules.homeManager; [
      system-desktop
      ssh
      tmux
      vw
      neovim-copilot
    ];

    home.username = "max";

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

      # company stuff, evaluated lazily as it is only reachable from the work network
      htt.packages.${pkgs.stdenv.hostPlatform.system}.default
    ];
  };
}
