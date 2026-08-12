{
  /**
  Creates a mount on the given destination from the provided host + resource

  # Type

  ```
  mount-cifs-nixos :: {[String] :: String} -> Module
  ```

  # Arguments

  server
  : The server address where the resouce is mounted from

  resource
  : The path to the resource which is being mounted

  destination
  : The path to the mount point

  credentialsName
  : Path to an age (un-)encrypted file containging the credentials to the host.
    Expected in the pattern of:
    ```
      username=xxx
      password=yyy
    ```

  username
  : Name of the user for which the mount is being made

  # Example

  ```nix
  {self, ...}: {
    flake.modules.nixos.<name> = {
      imports = [(self.factory.mount-cifs-nixos {
        server = "homeserver.lan";
        resource = "home";
        destination = "/home/users/max/homeserver";
        credentialsName = "homeserver-cred";
        username = "max";
      })];
    }
  }
  ```
  */
  config.flake.factory.mount-cifs-nixos = {
    server,
    resource,
    destination,
    credentialsName,
    username,
  }: {
    config,
    pkgs,
    ...
  }: let
    uid = toString config.users.users.${username}.uid;
    group = config.users.users.${username}.group;
    gid = toString config.users.groups.${group}.gid;
    credentialspath = config.age.secrets.${credentialsName}.path;
  in {
    environment.systemPackages = with pkgs; [cifs-utils];
    fileSystems."${destination}" = {
      device = "//${server}/${resource}";
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
        user = [
          "uid=${uid}"
          "gid=${gid}"
        ];
        credentials = ["credentials=${credentialspath}"];
      in
        automount-opts ++ mount-opts ++ user ++ credentials;
    };
  };
}
