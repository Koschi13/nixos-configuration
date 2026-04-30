{
  /**
  Configures audio for the given user(name).

  # Type

  ```
  audio :: String -> Module
  ```

  # Arguments

  username
  : The name of the user for which this aspect will be enabled

  # Example

  ```nix
  {self, ...}: {
    flake.modules.nixos.<name> = {
      imports = [(self.factory.audio "max")];
    }
  }
  ```
  */
  config.flake.factory.audio = username: {
    users.users.${username}.extraGroups = [
      "audio"
      "sound"
    ];
  };
}
