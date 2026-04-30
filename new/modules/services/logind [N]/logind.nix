{
  flake.modules = {
    nixos.logind = {
      services.logind.settings.Login = {
        # Size of /run/user/<uid>
        RuntimeDirectorySize = "6G";
      };
    };

    nixos.gnome-keyring = {
      security.pam.services.login.enableGnomeKeyring = true;
    };
  };
}
