{inputs, ...}: {
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
  ];

  perSystem = {config, ...}: {
    # `nix fmt`, also used by the `treefmt` git hook
    treefmt = {
      # The git root, so the old tree outside of `new/` is formatted as well
      projectRootFile = ".git/config";
      programs.alejandra.enable = true;
      # The sandbox only sees `new/`, while the tree root is the repository
      flakeCheck = false;
    };

    # The git hooks of the whole repository. `nix develop ./new` (or direnv)
    # installs them and links the generated `.pre-commit-config.yaml` into the
    # repository root.
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
