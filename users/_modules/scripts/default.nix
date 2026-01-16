{
  pkgs,
  lib,
  ...
}: let
  allFiles = builtins.readDir ./.;
  shFiles = lib.filterAttrs (name: type: lib.hasSuffix ".sh" name && type == "regular") allFiles;
  scriptNames = builtins.attrNames shFiles;
  scriptBins = map (script: pkgs.writeShellScriptBin (lib.removeSuffix ".sh" script) (builtins.readFile ./${script})) scriptNames;
in {
  home.packages = scriptBins;
}
