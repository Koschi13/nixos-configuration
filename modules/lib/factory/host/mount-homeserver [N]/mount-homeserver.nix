{inputs, ...}: {
  /**
  Sets up the homeserver mounts, owned by the given user.

  CIFS maps every file of a share to a single uid/gid, so unlike aspects
  using `dotfiles.users` the mounts can only belong to one user.

  # Type

  ```
  mount-homeserver :: { username :: String; } -> Module
  ```

  # Arguments

  An attribute set with:

  username
  : Name of the user owning the mounted files

  # Example

  ```nix
  {self, ...}: {
    flake.modules.nixos.<name> = {
      imports = [(self.factory.mount-homeserver {username = "max";})];
    }
  }
  ```
  */
  config.flake.factory.mount-homeserver = {username}: {
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
              "nofail"
              "soft"
              "x-systemd.idle-timeout=60"
              "x-systemd.device-timeout=5s"
              "x-systemd.mount-timeout=5s"
            ];
            mount-opts = [
              "rw"
              "iocharset=utf8"
            ];
            credentials = ["credentials=/etc/nixos/smb-secrets"];
            user = [
              "uid=${uid}"
              "gid=${gid}"
            ];
          in
            automount-opts ++ mount-opts ++ credentials ++ user;
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
