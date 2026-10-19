{self, ...}: {
  /**
  Configures greetd with a password login into the given window manager.

  There is no autologin on purpose: the password typed into the greeter is
  what unlocks the GNOME keyring through PAM.

  # Type

  ```
  greetd :: { hostname :: String; windowManager :: String; } -> { nixos.<hostname> :: Module; }
  ```

  # Arguments

  An attribute set with:

  hostname
  : The name of the host for which this aspect will be configured for


  windowManager
  : The name of the desired window manager

  # Example

  ```nix
  {self, ...}: {
    flake.modules = (self.factory.greetd {
      hostname = "alpha";
      windowManager = "sway";
    });
  }
  ```
  */
  config.flake.factory.greetd = {
    hostname,
    windowManager,
  }: {
    nixos.${hostname} = {pkgs, ...}: {
      # Make sure whatever windowManager is being used is imported
      imports = [
        self.modules.nixos.${windowManager}
      ];

      # Provides the greeter for the default session. Without it, greetd has
      # nothing to show and the graphical target never comes up. It remembers
      # the last user and session.
      services.displayManager.regreet.enable = true;

      services.greetd.enable = true;

      # Lists the session in the greeter. Only the `.desktop` entry is taken
      # from the package, it runs whatever `${windowManager}` is on the user's
      # PATH, as greetd sources /etc/profile before starting the session.
      services.displayManager.sessionPackages = [pkgs.${windowManager}];
    };
  };
}
