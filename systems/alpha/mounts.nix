{
  rootPath,
  config,
  pkgs,
  ...
}: let
  vars = import "${rootPath}/.secrets/mounts_vars.nix";
in {
  environment.systemPackages = [pkgs.cifs-utils];

  fileSystems = builtins.listToAttrs (map (mount: {
      name = mount.path;
      value = {
        device = mount.device;
        fsType = "cifs";
        options = let
          automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";
        in ["${automount_opts},credentials=/etc/nixos/smb-secrets,uid=${toString config.users.users.max.uid},gid=${toString config.users.groups.users.gid}"];
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
}
