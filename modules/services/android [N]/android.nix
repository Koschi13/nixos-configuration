{self, ...}: {
  # Access to Android devices through adb
  flake.modules.nixos.android = {pkgs, ...}: {
    imports = [self.modules.nixos.dotfiles-users];

    environment.systemPackages = with pkgs; [android-tools];

    dotfiles.userGroups = ["adbusers"];
  };
}
