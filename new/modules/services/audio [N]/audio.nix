{self, ...}: {
  flake.modules.nixos.audio = {
    config,
    lib,
    ...
  }: {
    imports = [self.modules.nixos.dotfiles-users];

    users.users = lib.genAttrs config.dotfiles.users (_: {
      extraGroups = [
        "audio"
        "sound"
      ];
    });
  };
}
