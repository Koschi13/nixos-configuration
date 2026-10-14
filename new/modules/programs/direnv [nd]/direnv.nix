{inputs, ...}: {
  flake.modules.homeManager.direnv = {pkgs, ...}: {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
        package = inputs.nixpkgsNixDirenv.legacyPackages.${pkgs.stdenv.hostPlatform.system}.nix-direnv;
      };
      silent = true;
    };
  };
}
