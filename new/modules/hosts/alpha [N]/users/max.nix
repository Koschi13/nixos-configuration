{inputs, ...}: {
  flake.modules.nixos.alpha = {config, ...}: {
    imports = with inputs.self.modules.nixos;
    with inputs.self.factory; [
      secrets # -> Sets up `age`
      max # -> imports users/max
      (mount-cifs-nixos {
        host = "homeserver";
        resource = "home";
        destination = "/home/users/max/homeserver";
        credentialspath = "${config.age.secrets."homeserver-cred".path}";
        UID = "max";
        GID = "users";
      })
    ];

    age.secrets."homeserver-cred" = {
      file = "${inputs.secrets}/homeserver-cred.age";
    };
  };
}
