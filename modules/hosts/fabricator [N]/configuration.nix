{self, ...}: let
  hostname = "fabricator";
in {
  flake.modules.nixos.fabricator = {
    imports = with self.modules.nixos; [
      system-cli

      glance

      backup
      firefly-iii
    ];

    networking.hostName = hostname;
  };
}
