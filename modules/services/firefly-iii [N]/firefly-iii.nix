{self, ...}: {
  # Firefly III, the personal finance manager, on http://firefly.lan, behind
  # `reverse-proxy`. The nixpkgs module adds its own virtual host.
  # Its data lives in the shared `postgresql` server, the attachments in
  # /var/lib/firefly-iii/storage/upload. With `backup`, both are backed up.
  #
  # Needs the `firefly-iii-app-key` secret of `secrets/README.md`.
  flake.modules.nixos.firefly-iii = {
    config,
    lib,
    ...
  }: let
    domain = "firefly.lan";
    # The service user and group, its database role and database. They have to
    # match, as the role authenticates as the user over the unix socket.
    name = "firefly";
  in {
    imports = with self.modules.nixos; [
      dotfiles-backup
      postgresql
      reverse-proxy
    ];

    # The attachments, everything else is in the database, which `postgresql`
    # backs up
    dotfiles.backup.paths = lib.mkIf config.dotfiles.backup.enable [
      "${config.services.firefly-iii.dataDir}/storage/upload"
    ];

    services.postgresql = {
      ensureDatabases = [name];
      ensureUsers = [
        {
          inherit name;
          ensureDBOwnership = true;
        }
      ];
    };

    # Firefly III formats amounts with `setlocale(LC_MONETARY, "<locale>.UTF-8")`
    # of the locale picked in the preferences. Without it installed, the UI
    # warns about an invalid server configuration.
    i18n.extraLocales = ["de_DE.UTF-8/UTF-8"];

    # PHP-FPM clears the environment of its workers, which would drop the
    # `LOCALE_ARCHIVE` glibc needs to find the locales above
    services.phpfpm.pools.firefly-iii.phpEnv.LOCALE_ARCHIVE =
      config.systemd.globalEnvironment.LOCALE_ARCHIVE;

    services.firefly-iii = {
      enable = true;
      user = name;
      group = name;
      enableNginx = true;
      virtualHost = domain;
      settings = {
        # The module defaults to https for every virtual host but localhost
        APP_URL = "http://${domain}";
        APP_KEY_FILE = config.age.secrets.firefly-iii-app-key.path;
        # `DB_HOST` defaults to the unix socket for pgsql, where the service
        # user authenticates as the role of the same name
        DB_CONNECTION = "pgsql";
        DB_DATABASE = name;
        DB_USERNAME = name;
        TZ = "Europe/Berlin";
        DEFAULT_LANGUAGE = "de_DE";
      };
    };

    # The module only creates its default user `firefly-iii`
    users = {
      users.${name} = {
        description = "Firefly III service user";
        isSystemUser = true;
        group = name;
        home = config.services.firefly-iii.dataDir;
      };
      groups.${name} = {};
    };

    age.secrets.firefly-iii-app-key = {
      file = "${self}/secrets/firefly-iii-app-key.age";
      owner = config.services.firefly-iii.user;
    };
  };
}
