{inputs, ...}: {
  /**
  Sets up the homeserver mounts for the given user(name)

  # Type

  ```
  mount-homeserver :: String -> Module
  ```

  # Arguments

  username
  : Name of the user for which the mount is being made

  # Example

  ```nix
  {self, ...}: {
    flake.modules.nixos.<name> = {
      imports = [(self.factory.mount-homeserver "max")];
    }
  }
  ```
  */
  config.flake.factory.mount-homeserver = username: {
    config,
    pkgs,
    ...
  }: let
    uid = toString config.users.users.${username}.uid;
    group = config.users.users.${username}.group;
    gid = toString config.users.groups.${group}.gid;

    vars = import "${inputs.git-crypt-secrets}/mounts_vars.nix";
  in {
    environment.systemPackages = with pkgs; [cifs-utils];

    fileSystems = builtins.listToAttrs (map (mount: {
        name = mount.path;
        value = {
          device = mount.device;
          fsType = "cifs";
          options = let
            # prevent hanging on network split
            automount-opts = [
              "x-systemd.automount"
              "noauto"
              "x-systemd.idle-timeout=60"
              "x-systemd.device-timeout=5s"
              "x-systemd.mount-timeout=5s"
            ];
            credentials = ["credentials=/etc/nixos/smb-secrets"];
            user = [
              "uid=${uid}"
              "gid=${gid}"
            ];
          in
            automount-opts ++ credentials ++ user;
        };
      })
      vars.mounts);

    environment.etc."nixos/smb-secrets" = {
      text = ''
        username=${vars.secrets.username}
        password=${vars.secrets.password}
      '';
      mode = "0600";
    };
  };
}
