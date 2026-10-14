{
  # Packages maintained in this repository, see `packages/`.
  #
  # They are exposed as flake outputs and, through the `local` overlay, as
  # `pkgs.local.<name>` so aspects don't need to know where they are defined.
  perSystem = {pkgs, ...}: {
    packages.compute_aspect_ratio = pkgs.callPackage ../packages/compute_aspect_ratio {};
  };

  flake.overlays.local = final: _prev: {
    local.compute_aspect_ratio = final.callPackage ../packages/compute_aspect_ratio {};
  };
}
