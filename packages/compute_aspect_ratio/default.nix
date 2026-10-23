# This applies the patch to the original file
{pkgs ? import <nixpkgs> {}}: let
  compute_aspect_ratio = pkgs.rustPlatform.buildRustPackage {
    pname = "compute_aspect_ratio";
    version = "0.1.0";

    src = ./.;

    cargoLock = {
      lockFile = ./Cargo.lock;
    };
  };
in
  # example package for wrapped cowsay
  pkgs.symlinkJoin {
    name = "compute_aspect_ratio";

    paths = [compute_aspect_ratio];
  }
