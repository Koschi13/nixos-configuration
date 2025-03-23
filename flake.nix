{
  description = "Maximilian Konter's system configuration";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## ZSH plugins which are not in nixpkgs
    zsh-calc = {
      url = "github:arzzen/calc.plugin.zsh";
      flake = false;
    };
    zsh-enhancd = {
      url = "github:babarot/enhancd";
      flake = false;
    };
    zsh-alias-finder = {
      url = "github:akash329d/zsh-alias-finder";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    home-manager,
    firefox-addons,
    zsh-calc,
    zsh-enhancd,
    zsh-alias-finder,
    ...
  } @ inputs: let
    # don't know what this is for, but without we do not have outputs available
    inherit (self) outputs;

    # Define what system we are, so we can re-use it
    system = "x86_64-linux";

    # Just an alias
    lib = nixpkgs.lib;
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    # NixOS configuration entrypoint
    # Available through 'nixos-rebuild --flake .#your-hostname'
    nixosConfigurations = {
      alpha = lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
          rootPath = ./.;
        };

        modules = [./systems/alpha/default.nix];
      };
      epsilon = lib.nixosSystem {
        specialArgs = {
          inherit inputs outputs;
        };

        modules = [
          ./systems/default.nix
          ./systems/epsilon/default.nix
        ];
      };
    };

    # Standalone home-manager configuration entrypoint
    # Available through 'home-manager --flake .#your-username@your-hostname'
    homeConfigurations = {
      "max" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit
            inputs
            outputs
            firefox-addons
            zsh-calc
            zsh-enhancd
            zsh-alias-finder
            ;
          rootPath = ./.;
        };
        modules = [./users/max/default.nix];
      };

      # This user will also be called "max"
      "scandio" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = {
          inherit
            inputs
            outputs
            firefox-addons
            zsh-calc
            zsh-enhancd
            zsh-alias-finder
            ;
          rootPath = ./.;
        };
        modules = [./users/scandio/default.nix];
      };
    };

    formatter."${system}" = pkgs.alejandra;
  };
}
