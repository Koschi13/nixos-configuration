{self, ...}: {
  # pgAdmin on http://pgadmin.lan, behind `reverse-proxy`, for the `postgresql`
  # server of the host. The server entry is declared below. Its password, the
  # `postgresql-admin-password` secret, is asked on the first connect; tick
  # "Save password" to keep it.
  #
  # Needs the `pgadmin-password` secret of `secrets/README.md`.
  flake.modules.nixos.pgadmin = {
    config,
    lib,
    pkgs,
    ...
  }: let
    pgadminConfig = config.services.pgadmin;

    # In the format of `pgadmin4-cli dump-servers`
    servers = pkgs.writeText "pgadmin-servers.json" (builtins.toJSON {
      Servers."1" = {
        Name = config.networking.hostName;
        Group = "Servers";
        Host = "localhost";
        Port = config.services.postgresql.settings.port;
        MaintenanceDB = "postgres";
        # The password of the `admin` user is defined in postgresql.nix
        Username = "admin";
        SSLMode = "prefer";
      };
    });
  in {
    imports = with self.modules.nixos; [
      postgresql
      reverse-proxy
    ];

    # pgAdmin listens on localhost only, as `openFirewall` is off
    services.nginx.virtualHosts."pgadmin.lan".locations."/".proxyPass = "http://127.0.0.1:${toString pgadminConfig.port}";

    services.pgadmin = {
      enable = true;
      port = 5050;
      initialEmail = "maximilian.konter@protonmail.com";
      # Read through `LoadCredential`, so root may own it
      initialPasswordFile = config.age.secrets.pgadmin-password.path;
    };

    # Loads the server entry of `servers` into the account of `initialEmail`,
    # after the module created it. Only when `servers` changed, as `--replace`
    # removes all servers of the account, including ones added in the UI and
    # their saved passwords.
    systemd.services.pgadmin.preStart = lib.mkAfter ''
      marker="$STATE_DIRECTORY/servers-loaded"
      if [ "$(cat "$marker" 2>/dev/null)" != ${servers} ]; then
        # Errors are only printed, so no server in the summary means it failed and
        # the next start tries again
        if ${pgadminConfig.package}/bin/pgadmin4-cli load-servers ${servers} \
            --user ${lib.escapeShellArg pgadminConfig.initialEmail} --replace \
            | tee /dev/stderr | grep -q 'and [1-9][0-9]* Server(s)'; then
          echo ${servers} > "$marker"
        fi
      fi
    '';

    age.secrets.pgadmin-password.file = "${self}/secrets/pgadmin-password.age";
  };
}
