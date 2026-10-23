{inputs, ...}: {
  # Packages maintained in this repository, see `packages/`.
  #
  # They are exposed as flake outputs and, through the `local` overlay, as
  # `pkgs.local.<name>` so aspects don't need to know where they are defined.
  #
  # The overlays are applied to every configuration by `mkNixos` / `mkDarwin`
  # (see `lib/lib.nix`) and to the `pkgs` of `perSystem`.
  perSystem = {
    pkgs,
    system,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system;
      overlays = [inputs.self.overlays.local inputs.self.overlays.stable];
    };

    packages.compute_aspect_ratio = pkgs.callPackage ../packages/compute_aspect_ratio {};
  };

  flake.overlays.local = final: _prev: {
    local.compute_aspect_ratio = final.callPackage ../packages/compute_aspect_ratio {};
  };

  # Escape hatch for packages broken on unstable, see `nixpkgs-stable` in
  # `systems/1 - default [NDn]/flake-file.nix`
  flake.overlays.stable = final: _prev: {
    stable = import inputs.nixpkgs-stable {
      # Not the whole config, unstable sets options stable doesn't accept
      config = {inherit (final.config) allowUnfree;};
      inherit (final.stdenv.hostPlatform) system;
    };
  };
}
