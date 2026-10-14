{self, ...}: {
  flake.modules.nixos.epsilon = let
    inherit (self) modules factory;
    username = "max";
  in {
    imports = [
      modules.nixos.${username} # -> imports users/max which sets up HomeManager
    ];
  };
}
