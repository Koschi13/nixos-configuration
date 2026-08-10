{
  /**
  Sets up USB automounting for the given user(name)

  # Type

  ```
  usb :: String -> Module
  ```

  # Arguments

  username
  : The name of the user for which this aspect will be enabled

  # Example

  ```nix
  {self, ...}: {
    flake.modules.nixos.<name> = {
      imports = [(self.factory.usb "max")];
    }
  }
  ```
  */
  config.flake.factory.usb = username: {
    services.devmon.enable = true;
    services.gvfs.enable = true;
    services.udisks2.enable = true;

    users.users.${username}.extraGroups = ["storage"];
  };
}
