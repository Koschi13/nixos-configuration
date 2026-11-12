{self, ...}: {
  # The Firefly III Data Importer on http://firefly-import.lan, behind
  # `reverse-proxy`, which imports CSV, CAMT and bank connections into the
  # `firefly-iii` of the same host. The nixpkgs module adds its own virtual
  # host. It keeps no data worth backing up, only uploads of running imports.
  #
  # It has no fixed token, so every import runs as the Firefly III user who
  # authorizes it: the importer asks for the ID of an OAuth client, created in
  # Firefly III under Options → Profile → OAuth → Create New Client, not
  # confidential, with the callback `http://firefly-import.lan/callback`.
  flake.modules.nixos.firefly-iii-data-importer = {config, ...}: let
    domain = "firefly-import.lan";
    fireflyUrl = config.services.firefly-iii.settings.APP_URL;
  in {
    imports = with self.modules.nixos; [
      firefly-iii
      reverse-proxy
    ];

    services.firefly-iii-data-importer = {
      enable = true;
      enableNginx = true;
      virtualHost = domain;
      settings = {
        # The module does not derive it from `virtualHost`, despite its docs
        APP_URL = "http://${domain}";
        # Where the importer calls the API, and the links it shows in the browser
        FIREFLY_III_URL = fireflyUrl;
        VANITY_URL = fireflyUrl;
        TZ = config.services.firefly-iii.settings.TZ;
        # The ICU locale that picks the decimal separator of CSV amounts,
        # when the amount alone does not tell, e.g. `1.000`
        FALLBACK_LOCALE = "de_DE";
      };
    };

    # The importer calls Firefly III by its name, which would otherwise depend
    # on the DNS of the gateway. nginx listens on loopback as well.
    networking.hosts."127.0.0.1" = [(builtins.replaceStrings ["http://"] [""] fireflyUrl)];
  };
}
