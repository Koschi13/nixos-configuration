{inputs, ...}: {
  imports = [
    inputs.flake-parts.flakeModules.modules
    # TODO: create the flake.nix yourself -- aligns with TODO.md
    inputs.flake-file.flakeModules.default
  ];

  # TODO: create the flake.nix yourself -- aligns with TODO.md
  flake-file = {
    inputs = {
      # Simplify Nix Flakes with the module system
      # https://github.com/hercules-ci/flake-parts
      flake-parts.url = "github:hercules-ci/flake-parts";

      # Generate flake.nix from module options.
      # https://github.com/vic/flake-file
      flake-file.url = "github:vic/flake-file";

      # Import all nix files in a directory tree.
      # https://github.com/vic/import-tree
      import-tree.url = "github:vic/import-tree";
    };

    # import all modules recursively with import-tree
    outputs = ''
      inputs: inputs.flake-parts.lib.mkFlake { inherit inputs; } (inputs.import-tree ./modules)
    '';
  };

  # TODO: set flake.systems -- aligns with TODO.md
  systems = [
    "aarch64-darwin"
    "aarch64-linux"
    "x86_64-darwin"
    "x86_64-linux"
  ];
}
