{self, ...}: {
  # The ING importer on http://firefly-ing.lan, behind `reverse-proxy`: takes
  # the CSV export of an ING account, converts it (see
  # `packages/firefly-importer-ing`), shows a preview and sends it to the
  # `firefly-iii-data-importer` of the same host, which imports it into
  # `firefly-iii`. Rules and account assignments live in its own database of
  # `postgresql`. An uploaded export is never stored: it stays in the memory
  # of the service until it is sent or discarded.
  #
  # Every user signs in as their Firefly III user, through an OAuth client
  # created in Firefly III under Options → Profile → OAuth → Create New
  # Client, not confidential, with the callback
  # `http://firefly-ing.lan/oauth/callback`. The importer's own client can't
  # be reused, a client has only one callback. The client ID and the tokens
  # are stored encrypted with the `firefly-importer-ing-key` secret.
  #
  # Turns on the `/autoupload` endpoint of the importer and gives it more
  # time and room for uploads.
  #
  # Needs the `firefly-importer-ing-key` and
  # `firefly-iii-data-importer-auto-import-secret` secrets of
  # `secrets/README.md`.
  flake.modules.nixos.firefly-importer-ing = {
    config,
    pkgs,
    ...
  }: let
    domain = "firefly-ing.lan";
    name = "firefly-importer-ing";
    host = "127.0.0.1";
    port = 8091;

    importer = config.services.firefly-iii-data-importer;
    fireflyUrl = config.services.firefly-iii.settings.APP_URL;
    autoImportSecret = config.age.secrets.firefly-iii-data-importer-auto-import-secret;

    # An import converts and imports while the upload request waits
    timeout = "900";
  in {
    imports = with self.modules.nixos; [
      firefly-iii
      firefly-iii-data-importer
      postgresql
      reverse-proxy
    ];

    users.users.${name} = {
      isSystemUser = true;
      group = name;
    };
    users.groups.${name} = {};

    services.postgresql = {
      ensureDatabases = [name];
      ensureUsers = [
        {
          inherit name;
          ensureDBOwnership = true;
        }
      ];
    };

    systemd.services.${name} = let
      package = pkgs.local.firefly-importer-ing;
    in {
      description = "ING importer for Firefly III";
      wantedBy = ["multi-user.target"];
      requires = ["postgresql.target"];
      after = ["network.target" "postgresql.target"];
      environment = {
        DATABASE_URL = "postgresql+psycopg:///${name}?host=/run/postgresql";
        FIREFLY_URL = fireflyUrl;
        IMPORTER_URL = "http://${importer.virtualHost}";
        PUBLIC_URL = "http://${domain}";
      };
      serviceConfig = {
        # Brings the database schema up to date
        ExecStartPre = "${package}/bin/firefly-importer-ing-migrate";
        ExecStart = builtins.concatStringsSep " " [
          "${package}/bin/firefly-importer-ing-serve"
          "--bind ${host}:${toString port}"
          # One worker only: it keeps the uploads in its memory, a second
          # one wouldn't know them
          "--workers 1 --worker-class gthread --threads 8"
          "--timeout ${timeout}"
          "--access-logfile -"
        ];
        User = name;
        Group = name;
        # Read by systemd before it drops privileges, so root may own them
        LoadCredential = [
          "secret-key:${config.age.secrets.firefly-importer-ing-key.path}"
          "auto-import-secret:${autoImportSecret.path}"
        ];
        Restart = "on-failure";

        CapabilityBoundingSet = "";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        ProcSubset = "pid";
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = ["@system-service" "~@privileged"];
        UMask = "0077";
      };
    };

    services.nginx.virtualHosts.${domain} = {
      extraConfig = "client_max_body_size 20m;";
      locations."/" = {
        proxyPass = "http://${host}:${toString port}";
        extraConfig = "proxy_read_timeout ${timeout}s;";
      };
    };

    # The importer's /autoupload, called by this service only
    services.firefly-iii-data-importer.settings = {
      CAN_POST_FILES = "true";
      AUTO_IMPORT_SECRET_FILE = autoImportSecret.path;
    };
    # Large uploads and imports that take minutes
    services.phpfpm.pools.firefly-iii-data-importer.phpOptions = {
      max_execution_time = timeout;
      upload_max_filesize = "20M";
      post_max_size = "20M";
    };
    services.nginx.virtualHosts.${importer.virtualHost} = {
      extraConfig = "client_max_body_size 20m;";
      locations."~ \\.php$".extraConfig = "fastcgi_read_timeout ${timeout}s;";
    };

    # This service calls the importer by its name, which would otherwise
    # depend on the DNS of the gateway. nginx listens on loopback as well.
    networking.hosts."127.0.0.1" = [importer.virtualHost];

    age.secrets = {
      # Encrypts the client IDs and tokens in the database and signs the
      # sessions
      firefly-importer-ing-key.file = "${self}/secrets/firefly-importer-ing-key.age";
      # Read by the importer's setup as its user, through `*_FILE`
      firefly-iii-data-importer-auto-import-secret = {
        file = "${self}/secrets/firefly-iii-data-importer-auto-import-secret.age";
        owner = importer.user;
      };
    };
  };
}
