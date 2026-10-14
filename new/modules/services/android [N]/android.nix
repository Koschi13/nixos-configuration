{self, ...}: {
  # Access to Android devices through adb
  flake.modules.nixos.android = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [self.modules.nixos.dotfiles-users];

    environment.systemPackages = with pkgs; [android-tools];

    users.users = lib.genAttrs config.dotfiles.users (_: {
      extraGroups = ["adbusers"];
    });
  };
}
