{
  flake.modules = {
    nixos.ssh = {
      services.openssh = {
        enable = true;
        openFirewall = true;
        settings = {
          PasswordAuthentication = true;
          PermitRootLogin = "no";
        };
      };
    };

    darwin.ssh = {
      services.openssh = {
        enable = true;
      };
    };

    homeManager.ssh = {
      # TODO: in conflict with openssh?
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
        settings = {
          "alpha.lan" = {
            hostname = "alpha.lan";
            user = "max";
            identityFile = "~/.ssh/yubikey.pub";
          };
        };
      };

      home.file.".ssh/yubikey.pub" = {
        source = ./yubikey.pub;
      };
    };
  };
}
