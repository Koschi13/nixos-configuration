{denisidoroCheats, ...}: let
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
      source = denisidoroCheats + "/cloud/cf.cheat";
    };
    "${cheatsDir}/code/git.cheat" = {
      source = denisidoroCheats + "/code/git.cheat";
    };
    "${cheatsDir}/container/docker.cheat" = {
      source = denisidoroCheats + "/container/docker.cheat";
    };
    "${cheatsDir}/container/kubernetes.cheat" = {
      source = denisidoroCheats + "/container/kubernetes.cheat";
    };
    "${cheatsDir}/misc/compression.cheat" = {
      source = denisidoroCheats + "/misc/compression.cheat";
    };
    "${cheatsDir}/misc/shell.cheat" = {
      source = denisidoroCheats + "/misc/shell.cheat";
    };
    "${cheatsDir}/misc/systemctl.cheat" = {
      source = denisidoroCheats + "/misc/systemctl.cheat";
    };
    "${cheatsDir}/network/curl.cheat" = {
      source = denisidoroCheats + "/network/curl.cheat";
    };
    "${cheatsDir}/network/network.cheat" = {
      source = denisidoroCheats + "/network/network.cheat";
    };
    "${cheatsDir}/security/gpg.cheat" = {
      source = denisidoroCheats + "/security/gpg.cheat";
    };
    "${cheatsDir}/security/openssl.cheat" = {
      source = denisidoroCheats + "/security/openssl.cheat";
    };
  };
}
