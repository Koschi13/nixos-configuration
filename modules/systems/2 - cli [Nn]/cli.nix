{self, ...}: {
  # The headless alternative to `system-desktop`
  flake.modules.nixos.system-cli = {
    imports = with self.modules.nixos; [
      system-default

      ssh
    ];

    # The tools of every user of this host
    home-manager.sharedModules = [self.modules.homeManager.system-cli];
  };

  flake.modules.homeManager.system-cli = {
    imports = with self.modules.homeManager; [
      system-default

      ssh
      tmux
    ];
  };
}
