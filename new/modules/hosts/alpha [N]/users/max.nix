{self, ...}: {
  flake.modules.nixos.alpha = let
    inherit (self) modules factory;
    username = "max";
  in {
    imports = [
      modules.nixos.${username} # -> imports users/max which sets up HomeManager

      (factory.audio username)
      (factory.gaming username)
      (factory.usb username)
      (factory.android username)
      (factory.mount-homeserver username)
    ];
  };
}
