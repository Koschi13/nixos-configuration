{inputs, ...}: {
  # `nix-locate` and the shell's command-not-found hook with a prebuilt
  # database, plus `, <command>` to run any program from nixpkgs without
  # installing it.
  flake.modules.homeManager.nix-index = {
    imports = [inputs.nix-index-database.homeModules.nix-index];

    programs.nix-index = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
    };
    programs.nix-index-database.comma.enable = true;
  };
}
