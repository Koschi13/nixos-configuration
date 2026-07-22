{
  flake.modules = {
    nixos.logind = {
      services.logind.settings.Login = {
        # Size of /run/user/<uid>
        RuntimeDirectorySize = "6G";
      };
      security.pam.services.logind.enableGnomeKeyring = true;
    };
  };
}
