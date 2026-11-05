{self, ...}: {
  flake.modules = {
    # The SSH server, for all users of a host. Only reachable with the key of
    # the YubiKey.
    #
    # root may log in from the trusted networks only, so deploys activate as
    # root with the YubiKey instead of relying on passwordless sudo.
    nixos.ssh = {
      config,
      lib,
      ...
    }: let
      trustedNetworks = [
        "192.168.1.0/24" # LAN
      ];
    in {
      imports = [self.modules.nixos.dotfiles-users];

      services.openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = false;
          KbdInteractiveAuthentication = false;
          PermitRootLogin = "no";
          # Lets a new connection replace the socket of a forwarded gpg-agent
          StreamLocalBindUnlink = "yes";
        };
        extraConfig = ''
          Match Address ${lib.concatStringsSep "," trustedNetworks}
            PermitRootLogin prohibit-password
        '';
      };

      users.users = lib.genAttrs (config.dotfiles.users ++ ["root"]) (_: {
        openssh.authorizedKeys.keyFiles = [./yubikey.pub];
      });
    };

    # Generic SSH client setup. Hosts add their match blocks through
    # `programs.ssh.settings`, e.g. `hosts/epsilon [N]/users/max.nix`.
    homeManager.ssh = {
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
      };

      # The public key of the YubiKey, so `identityFile` can select it from the
      # gpg-agent
      home.file.".ssh/yubikey.pub" = {
        source = ./yubikey.pub;
      };
    };
  };
}
