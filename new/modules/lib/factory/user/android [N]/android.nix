{
  /**
  Configures android-tools for the given user(name).

  # Type

  ```
  android :: String -> Module
  ```

  # Arguments

  username
  : The name of the user for which this aspect will be enabled

  # Example

  ```nix
  {self, pkgs, ...}: {
    flake.modules = (self.factory.android "max");
  }
  ```
  */
  config.flake.factory.android = username: {
    nixos.${username} = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [android-tools];

      users.users.${username}.extraGroups = ["adbusers"];
    };
  };
}
