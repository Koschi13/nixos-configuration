/**
Creates a mount on the given destination from the provided host + resource

# Type

```
mount-cifs-nixos :: String -> String -> String -> String -> String -> String -> Module
```

# Arguments

host
: The host of the resource

resource
: The path to the resource which is being mounted

destination
: The path to the mount point

credentialspath
: Path to an age (un-)encrypted file containging the credentials to the host.
  Expected in the pattern of:
  ```
    username=xxx
    password=yyy
  ```

UID
: The UID of the user the mount is being made for

GID
: The GID of the user the mount is being made for

# Example

```nix
{self, pkgs, ...}: {
  flake.modules = (self.factory.user "max", true);
}
```
*/
{
  config.flake.factory.mount-cifs-nixos = {
    host,
    resource,
    destination,
    credentialspath,
    UID,
    GID,
  }: {pkgs, ...}: {
    environment.systemPackages = [pkgs.cifs-utils];

    fileSystems."${destination}" = {
      device = "//${host}/${resource}";
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
          "uid=${UID}"
          "gid=${GID}"
        ];
        credentials = ["credentials=${credentialspath}"];
      in
        automount-opts ++ mount-opts ++ user ++ credentials;
    };
  };
}
