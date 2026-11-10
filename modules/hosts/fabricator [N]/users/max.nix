{self, ...}: {
  flake.modules.nixos.fabricator = let
    inherit (self) modules;
    username = "max";
  in {
    imports = [
      modules.nixos.${username} # -> imports users/max which sets up HomeManager
    ];
  };
}
