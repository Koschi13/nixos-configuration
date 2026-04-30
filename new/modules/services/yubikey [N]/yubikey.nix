{self, ...}: {
  flake.modules.nixos.yubikey = {pkgs, ...}: {
    imports = with self.modules.nixos; [
      gpg
    ];

    services.udev.packages = with pkgs; [yubikey-personalization];
    services.pcscd.enable = true;
    environment.systemPackages = with pkgs; [pcsclite];
  };
}
