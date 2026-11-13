{self, ...}: {
  # The PostgreSQL server of a host, shared by all its services. A service adds
  # its own database and role in its aspect, connecting over the unix socket
  # with peer authentication, so it needs no password:
  #
  # ```nix
  # services.postgresql = {
  #   ensureDatabases = ["<name>"];
  #   ensureUsers = [{name = "<name>"; ensureDBOwnership = true;}];
  # };
  # ```
  #
  # With `backup`, every backup contains a fresh dump of all databases.
  #
  # The `admin` superuser is for tools connecting over TCP, like `pgadmin`.
  # Needs the `postgresql-admin-password` secret of `secrets/README.md`.
  flake.modules.nixos.postgresql = {
    config,
    lib,
    pkgs,
    ...
  }: {
    # Every service with a database imports this aspect. The key lets the
    # module system deduplicate it, see `lib/users [N]/users.nix`.
    key = "postgresql";

    imports = [self.modules.nixos.dotfiles-backup];

    services.postgresql = {
      enable = true;
      # Major upgrades need a manual dump and restore, so the version must not
      # move with nixpkgs
      package = pkgs.postgresql_18;
      # The default authentication stays: `peer` on the unix socket and a
      # password on localhost, the server isn't reachable from the network
      ensureUsers = [
        {
          name = "admin";
          ensureClauses.superuser = true;
        }
      ];
    };

    age.secrets.postgresql-admin-password = {
      file = "${self}/secrets/postgresql-admin-password.age";
      owner = "postgres";
    };

    # Runs right before every backup instead of on its own timer, so the backup
    # always contains a fresh dump. restic compresses and deduplicates itself,
    # a compressed dump would defeat the deduplication.
    services.postgresqlBackup = lib.mkIf config.dotfiles.backup.enable {
      enable = true;
      backupAll = true;
      compression = "none";
      startAt = [];
    };

    dotfiles.backup = lib.mkIf config.dotfiles.backup.enable {
      paths = [config.services.postgresqlBackup.location];
      requiredServices = ["postgresqlBackup.service"];
    };

    # `ensureUsers` can't set passwords. psql reads the secret itself with the
    # backtick of `\set`, so it never shows up in the process list.
    systemd.services.postgresql-setup.script = lib.mkAfter ''
      psql -d postgres -v ON_ERROR_STOP=1 <<'EOF'
        \set password `cat ${config.age.secrets.postgresql-admin-password.path}`
        ALTER ROLE admin WITH PASSWORD :'password';
      EOF
    '';
  };
}
