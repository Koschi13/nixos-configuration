{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
  ];

  perSystem = {config, ...}: {
    # `nix fmt`, also used by the `treefmt` git hook
    treefmt.programs.alejandra.enable = true;

    # The git hooks of the repository. `nix develop` (or direnv) installs them
    # and links the generated `.pre-commit-config.yaml` into the repository
    # root.
    pre-commit = {
      # gitleaks needs the git history, which the sandbox doesn't have
      check.enable = false;
      settings.hooks = {
        treefmt.enable = true;
        gitleaks.enable = true;
      };
    };

    devShells.default = config.pre-commit.devShell;
  };
}
