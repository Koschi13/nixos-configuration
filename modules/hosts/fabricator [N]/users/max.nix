{self, ...}: {
  flake.modules.nixos.fabricator = let
    inherit (self) modules;
    username = "max";
  in {
    imports = [
      modules.nixos.${username} # -> imports users/max which sets up HomeManager
    ];

    # Starts the user manager at boot, so the directory of the forwarded
    # gpg-agent sockets exists before the first login
    users.users.${username}.linger = true;
  };
}
