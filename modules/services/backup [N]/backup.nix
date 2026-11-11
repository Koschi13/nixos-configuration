{self, ...}: {
  # Daily restic backup to the Hetzner Storage Box. What it contains, the
  # aspects of the host declare through `dotfiles.backup`, see
  # `lib/backup [N]/backup.nix`. Each host has its own repository behind its
  # own sub-account of the Storage Box, so one host can't delete the backups of
  # another.
  #
  # Needs the `restic-<hostname>-*` secrets of `secrets/README.md` for the
  # importing host.
  #
  # Inspect and restore with the `restic-storagebox` wrapper, e.g.
  # `sudo restic-storagebox snapshots`.
  flake.modules.nixos.backup = {
    config,
    lib,
    ...
  }: let
    inherit (config.networking) hostName;
    secretPrefix = "restic-${hostName}";
    secrets = config.age.secrets;
    user = "restic";
    # Home of `user`, holds the known_hosts of the Storage Box, pinned on first
    # connect
    stateDirectory = "/var/lib/restic-storagebox";
  in {
    imports = [self.modules.nixos.dotfiles-backup];

    dotfiles.backup.enable = true;

    services.restic.backups.storagebox = {
      # Relative to the home directory of the sub-account
      repository = "sftp:storagebox:restic";
      passwordFile = secrets."${secretPrefix}-password".path;
      extraOptions = [
        "sftp.command='ssh -F ${secrets."${secretPrefix}-ssh-config".path} storagebox -s sftp'"
      ];
      inherit user;
      initialize = true;
      inherit (config.dotfiles.backup) paths;
      timerConfig = {
        OnCalendar = "*-*-* 03:00:00";
        RandomizedDelaySec = "30m";
        Persistent = true;
      };
      pruneOpts = [
        "--keep-daily 7"
        "--keep-weekly 5"
        "--keep-monthly 12"
        "--keep-yearly 3"
      ];
      runCheck = true;
    };

    systemd.services.restic-backups-storagebox = {
      requires = config.dotfiles.backup.requiredServices;
      after = config.dotfiles.backup.requiredServices;
      # Reads every file regardless of its permissions, so the aspects don't
      # have to share their files, but unlike root it can't write anything
      # outside its own directories
      serviceConfig = {
        AmbientCapabilities = ["CAP_DAC_READ_SEARCH"];
        CapabilityBoundingSet = ["CAP_DAC_READ_SEARCH"];
      };
    };

    users = {
      users.${user} = {
        description = "restic backup user";
        isSystemUser = true;
        group = user;
        home = stateDirectory;
      };
      groups.${user} = {};
    };

    systemd.tmpfiles.rules = ["d ${stateDirectory} 0700 ${user} ${user} - -"];

    age.secrets = lib.genAttrs ["${secretPrefix}-password" "${secretPrefix}-ssh-key" "${secretPrefix}-ssh-config"] (name: {
      file = "${self}/secrets/${name}.age";
      owner = user;
    });
  };
}
