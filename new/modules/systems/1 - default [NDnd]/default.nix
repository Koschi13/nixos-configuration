{inputs, ...}: let
  stateVersion = "26.05";
  stateVersionDarwin = 7;

  experimental-features = [
    "nix-command"
    "flakes"
  ];
in {
  flake.modules.nixos.system-default = {
    imports = with inputs.self.modules.nixos; [
      # services
      cachix
      firmware # TODO@comp disable
      logind
      ssh

      # lib/tools
      home-manager # This wires Home-Manager into the system
    ];

    nix.settings = {
      experimental-features = experimental-features;
      trusted-users = [
        "root"
        "@wheel"
      ];
    };

    system.stateVersion = stateVersion;
  };

  flake.modules.darwin.system-default = {
    import = with inputs.self.modules.darwin; [
      # services
      cachix
      ssh
      # lib/tools
      home-manager # This wires Home-Manager into the system
    ];

    nix.settings.experimental-features = experimental-features;

    system.stateVersion = stateVersionDarwin;
  };

  flake.modules.homeManager.system-default = {
    pkgs,
    lib,
    config,
    ...
  }: {
    home.homeDirectory =
      if pkgs.stdenv.isDarwin
      then (lib.mkForce "/Users/${config.home.username}")
      else "/home/${config.home.username}";
    home.stateVersion = stateVersion;
  };
}
