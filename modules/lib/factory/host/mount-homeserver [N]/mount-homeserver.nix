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
    lib,
    pkgs,
    ...
  }: let
    uid = toString config.users.users.${username}.uid;
    group = config.users.users.${username}.group;
    gid = toString config.users.groups.${group}.gid;

    # Without the credentials, as the parser of the master map rejects the `/`
    # of their path. The map entries add them, see `homeserver-map` below.
    mountOptions = lib.concatStringsSep "," [
      "-fstype=cifs"
      "rw"
      "soft" # prevent hanging on network split
      "iocharset=utf8"
      "uid=${uid}"
      "gid=${gid}"
    ];
  in {
    environment.systemPackages = with pkgs; [cifs-utils];

    # The shares are mounted on access and unmounted when idle. autofs instead
    # of `fileSystems`, as that needs the shares at evaluation and they would
    # end up in this public repository and the Nix store.
    services.autofs = {
      enable = true;
      timeout = 60;
      autoMaster = "/- file:${config.age.secrets.homeserver-map.path} ${mountOptions}";
    };

    # The path of the map stays the same when its content changes
    systemd.services.autofs.restartTriggers = [config.age.secrets.homeserver-map.file];

    # Their content is documented in `secrets/README.md`
    age.secrets = {
      homeserver-map = {
        file = "${inputs.self}/secrets/homeserver-map.age";
        mode = "0400";
      };
      # The path is fixed, as the map refers to it
      smb-credentials = {
        file = "${inputs.self}/secrets/smb-credentials.age";
        path = "/run/agenix/smb-credentials";
        mode = "0400";
      };
    };
  };
}
