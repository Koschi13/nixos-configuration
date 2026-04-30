{
  /**
  Configures qemu and other virtualisation related stuff for the given user(name)

  # Type

  ```
  virtualisation :: String -> [String] -> String -> Module
  ```

  # Arguments

  host
  : The host for which this configuration will be active

  users
  : A list of users which will be added to the `kvm` group

  cpu
  : The CPU vendor. Valid values: ["amd" "intel"]

  # Example

  ```nix
  {self, pkgs, ...}: {
    flake.modules = (self.factory.virtualisation "alpha" ["max"] "amd");
  }
  ```
  */
  config.flake.factory.virtualisation = host: users: cpuVendor: {
    nixos.${host} = {
      pkgs,
      lib,
      ...
    }: {
      programs.virt-manager.enable = true;

      virtualisation.libvirtd = {
        enable = true;
        onBoot = "ignore";
        onShutdown = "shutdown";

        qemu = {
          package = pkgs.qemu_kvm;
          runAsRoot = true;
          swtpm.enable = true;
        };
      };

      boot.kernelModules =
        if lib.strings.toLower cpuVendor == "amd"
        then ["kvm-amd"]
        else if lib.strings.toLower cpuVendor == "intel"
        then ["kvm-intel"]
        else [];

      users.users = builtins.listToAttrs (map (username: {
          name = username;
          value = {extraGroups = ["kvm"];};
        })
        users);
    };
  };
}
