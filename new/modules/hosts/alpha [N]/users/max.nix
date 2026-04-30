{
  inputs,
  self,
  ...
}: {
  # TODO
  flake.modules.nixos.alpha = {config, ...}: {
    imports = with inputs.self.modules.nixos;
    with inputs.self.factory; [
      max
      (mount-cifs-nixos {
        host = "home-server.lan";
        resource = "home";
        destination = "/home/users/max/homeserver";
        credentialspath = "${config.age.secrets."homeserver-cred".path}";
        UID = "max";
        GID = "users";
      })
    ];

    age.secrets."homeserver-cred" = {
      file = "${self.inputs.secrets}/homeserver-cred.age";
    };

    # ...

    home-manager.users.max = {
      ###
    };
  };
}
