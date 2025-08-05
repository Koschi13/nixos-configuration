# This applies the patch to the original file
{pkgs}: let
  compute_aspect_ratio = pkgs.rustPlatform.buildRustPackage {
    pname = "compute_aspect_ratio";
    version = "0.1.0";

    src = ./.;

    cargoLock = {
      lockFile = ./Cargo.lock;
    };
  };
in
  compute_aspect_ratio
