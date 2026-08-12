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
      };
    };
  };
}
