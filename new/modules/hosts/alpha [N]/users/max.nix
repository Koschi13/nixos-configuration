{
  self,
  inputs,
  ...
}: {
  flake.modules.nixos.alpha = let
    inherit (self) modules factory;
  in {
    imports = [
      modules.nixos.secrets # -> Sets up `age`
      modules.nixos.max # -> imports users/max which sets up HomeManager
      (factory.mount-cifs-nixos {
        server = "homeserver.lan";
        resource = "home";
        destination = "/home/users/max/homeserver";
        credentialsName = "homeserver-cred";
        username = "max";
      })
    ];

    age.secrets."homeserver-cred" = {
      file = "${inputs.secrets}/homeserver-cred.age";
    };
  };
}
