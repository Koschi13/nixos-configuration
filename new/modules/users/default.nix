{self, ...}: {
  flake.homeConfigurations = self.lib.mkHomeManager "x86_64-linux" "max";
}
