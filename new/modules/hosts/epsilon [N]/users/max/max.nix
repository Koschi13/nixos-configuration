{self, ...}: {
  flake.modules.nixos.epsilon = {
    imports = [
      self.modules.nixos.max # -> imports users/max which sets up HomeManager
    ];
  };
}
