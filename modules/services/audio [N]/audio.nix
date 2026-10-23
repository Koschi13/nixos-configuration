{self, ...}: {
  flake.modules.nixos.audio = {
    imports = [self.modules.nixos.dotfiles-users];

    dotfiles.userGroups = ["audio" "sound"];
  };
}
