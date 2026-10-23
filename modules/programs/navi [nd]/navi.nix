{inputs, ...}: {
  flake.modules.homeManager.navi = {config, ...}: let
    cheatsDir = "navi/cheats";
  in {
    programs.navi = {
      enable = true;

      # Start with <C+G>
      enableZshIntegration = true;
      enableBashIntegration = true;
    };

    # Set explicitly, so other places (like a repository's `.envrc`) can extend
    # it instead of hardcoding the default
    home.sessionVariables.NAVI_PATH = "${config.xdg.dataHome}/${cheatsDir}";

    xdg.dataFile = {
      "${cheatsDir}" = {
        source = ./cheats;
        recursive = true;
      };
      "${cheatsDir}/cloud/cf.cheat" = {
        source = inputs.denisidoro-cheats + "/cloud/cf.cheat";
      };
      "${cheatsDir}/code/git.cheat" = {
        source = inputs.denisidoro-cheats + "/code/git.cheat";
      };
      "${cheatsDir}/container/docker.cheat" = {
        source = inputs.denisidoro-cheats + "/container/docker.cheat";
      };
      "${cheatsDir}/container/kubernetes.cheat" = {
        source = inputs.denisidoro-cheats + "/container/kubernetes.cheat";
      };
      "${cheatsDir}/misc/compression.cheat" = {
        source = inputs.denisidoro-cheats + "/misc/compression.cheat";
      };
      "${cheatsDir}/misc/shell.cheat" = {
        source = inputs.denisidoro-cheats + "/misc/shell.cheat";
      };
      "${cheatsDir}/misc/systemctl.cheat" = {
        source = inputs.denisidoro-cheats + "/misc/systemctl.cheat";
      };
      "${cheatsDir}/network/curl.cheat" = {
        source = inputs.denisidoro-cheats + "/network/curl.cheat";
      };
      "${cheatsDir}/network/network.cheat" = {
        source = inputs.denisidoro-cheats + "/network/network.cheat";
      };
      "${cheatsDir}/security/gpg.cheat" = {
        source = inputs.denisidoro-cheats + "/security/gpg.cheat";
      };
      "${cheatsDir}/security/openssl.cheat" = {
        source = inputs.denisidoro-cheats + "/security/openssl.cheat";
      };
    };
  };
}
