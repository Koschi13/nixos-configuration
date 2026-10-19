{
  inputs,
  self,
  lib,
  ...
}: let
  stateVersion = import ./_stateVersion.nix;

  experimental-features = [
    "nix-command"
    "flakes"
  ];

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  # `htt` is left out, as it is only reachable from the work network and
  # would otherwise have to be fetched by every host.
  registry = lib.mapAttrs (_: flake: {inherit flake;}) (removeAttrs inputs ["htt"]);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") registry;

  gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 10d";
  };

  # Settings shared by the `nixos` and `darwin` classes
  shared = {pkgs, ...}: {
    nix = {
      inherit gc registry nixPath;
      settings = {
        auto-optimise-store = true;
        experimental-features = experimental-features;
      };
    };

    time.timeZone = "Europe/Berlin";

    nixpkgs.overlays = [
      self.overlays.local
      (final: _prev: {
        stable = import inputs.nixpkgs-stable {
          inherit (final) config;
          system = pkgs.stdenv.hostPlatform.system;
        };
      })
    ];

    # git-crypt decrypts the secrets this flake imports, so it has to be
    # available before the first switch to this configuration.
    environment.systemPackages = with pkgs; [git git-crypt wget curl];
    documentation.doc.enable = false;
  };
in {
  flake.modules.nixos.system-default = {
    imports =
      [shared]
      ++ (with self.modules.nixos; [
        # lib
        dotfiles-cpu

        # services
        firmware
        logind
        gpg
        yubikey
        shell
        neovim

        # lib/tools
        home-manager # This wires Home-Manager into the system
      ]);

    time.hardwareClockInLocalTime = true;

    networking = {
      networkmanager = {
        enable = true;
      };
    };

    nixpkgs.config.allowUnfree = true;

    boot.tmp.cleanOnBoot = true;
    system.stateVersion = stateVersion.nixOs;
    programs.nix-ld.enable = true;
  };

  flake.modules.darwin.system-default = {
    imports =
      [shared]
      ++ (with self.modules.darwin; [
        # services
        cachix
        yubikey
        shell

        # lib/tools
        home-manager # This wires Home-Manager into the system
      ]);

    system.stateVersion = stateVersion.darwin;
  };

  flake.modules.homeManager.system-default = {
    pkgs,
    config,
    ...
  }: {
    imports = with self.modules.homeManager; [
      shell
      neovim
      git
      direnv
      navi
      nh
      gpg
      agents
      herdr
    ];

    home.packages = with pkgs; [ripgrep fd];

    home.homeDirectory =
      if pkgs.stdenv.hostPlatform.isDarwin
      then (lib.mkForce "/Users/${config.home.username}")
      else "/home/${config.home.username}";
    home.stateVersion = stateVersion.homeManager;
    home.sessionPath = ["$HOME/.local/bin"];

    # Nicely reload system units when changing configs
    systemd.user.startServices = "sd-switch";
  };
}
