{lib, ...}: {
  # factory: storage for factory aspect functions

  options.flake.factory = lib.mkOption {
    type = lib.types.attrsOf lib.types.unspecified;
    default = {};
    description = "Generic factory definition. See https://github.com/Doc-Steve/dendritic-design-with-flake-parts/wiki/Dendritic_Aspects#factory-aspect";
  };
}
