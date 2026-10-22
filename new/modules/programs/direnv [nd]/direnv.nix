{inputs, ...}: {
  flake.modules.homeManager.direnv = {pkgs, ...}: {
    programs.direnv = {
      enable = true;
      enableBashIntegration = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
        package = inputs.nixpkgs-nix-direnv.legacyPackages.${pkgs.stdenv.hostPlatform.system}.nix-direnv;
      };
      silent = true;
    };
  };
}
