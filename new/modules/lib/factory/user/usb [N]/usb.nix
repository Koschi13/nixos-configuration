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
    flake.modules = (self.factory.usb "max");
  }
  ```
  */
  config.flake.factory.usb = username: {
    nixos.${username} = {
      services.devmon.enable = true;
      services.gvfs.enable = true;
      services.udisks2.enable = true;

      users.users.${username}.extraGroups = ["storage"];
    };
  };
}
