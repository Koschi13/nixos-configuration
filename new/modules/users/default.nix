{
  self,
  lib,
  ...
}: {
  flake.homeConfigurations = lib.mkMerge [
    (self.lib.mkHomeManager "x86_64-linux" "max")
    # Work setup of max, named after the old configuration to keep
    # `home-manager switch --flake .#hiq` working.
    (self.lib.mkHomeManager "x86_64-linux" "hiq")
  ];
}
