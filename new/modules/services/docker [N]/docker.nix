{
  flake.modules = {
    nixos.docker = {
      virtualisation = {
        docker = {
          enable = true;
          # All hosts are desktops, containers are started on demand
          enableOnBoot = false;
          rootless = {
            enable = true;
            setSocketVariable = true;
          };
        };
      };
    };
  };
}
