{pkgsNixDirenv, ...}: {
  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
    nix-direnv = {
      package = pkgsNixDirenv.nix-direnv;
      enable = true;
    };
    silent = true;
  };
}
