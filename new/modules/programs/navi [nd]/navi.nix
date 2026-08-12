{inputs, ...}: {
  flake.modules.homeManager.navi = {...}: let
    cheatsDir = ".local/share/navi/cheats";
  in {
    programs.navi = {
      enable = true;

      # Start with <C+G>
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    home.file = {
      "${cheatsDir}" = {
        source = ./cheats;
        recursive = true;
      };
      "${cheatsDir}/cloud/cf.cheat" = {
        source = inputs.denisidoroCheats + "/cloud/cf.cheat";
      };
      "${cheatsDir}/code/git.cheat" = {
        source = inputs.denisidoroCheats + "/code/git.cheat";
      };
      "${cheatsDir}/container/docker.cheat" = {
        source = inputs.denisidoroCheats + "/container/docker.cheat";
      };
      "${cheatsDir}/container/kubernetes.cheat" = {
        source = inputs.denisidoroCheats + "/container/kubernetes.cheat";
      };
      "${cheatsDir}/misc/compression.cheat" = {
        source = inputs.denisidoroCheats + "/misc/compression.cheat";
      };
      "${cheatsDir}/misc/shell.cheat" = {
        source = inputs.denisidoroCheats + "/misc/shell.cheat";
      };
      "${cheatsDir}/misc/systemctl.cheat" = {
        source = inputs.denisidoroCheats + "/misc/systemctl.cheat";
      };
      "${cheatsDir}/network/curl.cheat" = {
        source = inputs.denisidoroCheats + "/network/curl.cheat";
      };
      "${cheatsDir}/network/network.cheat" = {
        source = inputs.denisidoroCheats + "/network/network.cheat";
      };
      "${cheatsDir}/security/gpg.cheat" = {
        source = inputs.denisidoroCheats + "/security/gpg.cheat";
      };
      "${cheatsDir}/security/openssl.cheat" = {
        source = inputs.denisidoroCheats + "/security/openssl.cheat";
      };
    };
  };
}
