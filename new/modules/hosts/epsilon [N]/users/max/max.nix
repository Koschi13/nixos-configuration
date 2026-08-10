{
  self,
  inputs,
  ...
}: {
  flake.modules.nixos.epsilon = let
    inherit (self) modules factory;
    username = "max";
  in {
    imports = [
      modules.nixos.secrets # -> Sets up `age`
      modules.nixos.${username} # -> imports users/max which sets up HomeManager

      (factory.audio username)
      (factory.usb username)
      (factory.mount-cifs-nixos {
        server = "homeserver.lan";
        resource = "home";
        destination = "/home/users/max/homeserver";
        credentialsName = "homeserver-cred";
        inherit username;
      })
    ];

    age.secrets."homeserver-cred" = {
      file = "${inputs.secrets}/homeserver-cred.age";
    };
  };
}
