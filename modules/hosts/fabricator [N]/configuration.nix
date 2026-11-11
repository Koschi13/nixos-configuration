{self, ...}: let
  hostname = "fabricator";
in {
  flake.modules.nixos.fabricator = {
    imports = with self.modules.nixos; [
      system-cli

      glance
    ];

    networking.hostName = hostname;
  };
}
