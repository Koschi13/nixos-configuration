{
  description = "Maximilian Konter's system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nur } @ inputs:
  let
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      inherit system;
      config = { allowUnfree = true; };
      overlays = [
        nur.overlay
      ];
    };

    lib = nixpkgs.lib;

  in {
    nixosConfigurations = {
      alpha = lib.nixosSystem {
        inherit system pkgs;

	modules = [
	  ./systems/alpha/configuration.nix
	  home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true; # makes hm use nixos's pkgs value
            home-manager.useUserPackages = true; # ???
            home-manager.users.max.imports = [ ./users/max/home.nix ];
          }
	];
      };
    };
  };
}
