{
  /**
  Generates the LUKS configuration, so the boot loader knows where to find
  the system and how to decrypt it.

  # Type

  ```
  luks :: String -> String -> Bool -> Module
  ```

  # Arguments

  host
  : The name of the host the module will be generated for.

  uuid
  : The UUID of the device which is luks encrypted

  ssd
  : Whether or not the device is an SSD. This will enable the `allowDiscards`
    option, which improves the performance a bit.

  # Example

  ```nix
  {self, ...}: {
    flake.modules = (self.factory.luks "alpha" "8e424358-602c-490d-9a00-ad3d00108f32");
  }
  ```
  */
  config.flake.factory.luks = host: uuid: ssd: {
    nixos."${host}" = {
      boot = {
        initrd = {
          luks.devices.luksroot = {
            name = "luksroot";
            device = "/dev/disk/by-uuid/${uuid}";
            preLVM = true;
            allowDiscards = ssd;
          };
        };
      };
    };
  };
}
