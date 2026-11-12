{self, ...}: let
  hostname = "fabricator";
in {
  flake.modules.nixos.fabricator = {
    imports = with self.modules.nixos; [
      system-cli

      glance

      backup
      firefly-iii
      firefly-iii-data-importer
      pgadmin
    ];

    networking.hostName = hostname;
  };
}
