# This applies the patch to the original file
{pkgs}: let
  originalFile = ../../astronvim/lua/community.lua;
  patchFile = ./community.patch;

  patchedCommunityLua = pkgs.stdenv.mkDerivation {
    name = "patchedCommunityLua";
    src = ./.;

    buildPhase = ''
      mkdir -p $out
      cp ${originalFile} $out/community.lua
      patch $out/community.lua < ${patchFile}
    '';

    nativeBuildInputs = [pkgs.patch];
  };
in
  patchedCommunityLua
