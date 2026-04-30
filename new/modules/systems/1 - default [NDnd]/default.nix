{
  inputs,
  lib,
  ...
}: let
  stateVersion = import ./_stateVersion.nix;

  experimental-features = [
    "nix-command"
    "flakes"
  ];

  # TODO: These two statements were adapted to nyx way of doing it, since the
  #       default pattern I found on the internet wasn't working

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  registry = lib.mapAttrs (_: flake: {inherit flake;}) inputs;

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nixPath = lib.mapAttrsToList (key: _: "${key}=flake:${key}") registry;

  gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 10d";
  };

  packages = pkgs: with pkgs; [git wget curl];
in {
  flake.modules.nixos.system-default = {pkgs, ...}: {
    imports = with inputs.self.modules.nixos; [
      # services
      cachix
      firmware # TODO@comp disable
      logind
      ssh
      yubikey

      # lib/tools
      home-manager # This wires Home-Manager into the system
    ];

    nix = {
      inherit gc registry nixPath;
      settings = {
        auto-optimise-store = true;
        experimental-features = experimental-features;
        trusted-users = [
          "root"
          "@wheel"
        ];
      };
    };

    time = {
      timeZone = "Europe/Berlin";
      hardwareClockInLocalTime = true;
    };

    networking = {
      networkmanager = {
        enable = true;
      };
    };

    # TODO: Apply usage of `unstable` for all programs
    nixpkgs.overlays = [
      (final: _prev: {
        stable = import inputs.nixpkgs-unstable {
          inherit (final) config;
          system = pkgs.stdenv.hostPlatform.system;
        };
      })
    ];
    nixpkgs.config.allowUnfree = true;

    environment.systemPackages = packages pkgs;
    documentation.doc.enable = false;
    boot.tmp.cleanOnBoot = true;
    system.stateVersion = stateVersion.nixOs;
  };

  flake.modules.darwin.system-default = {pkgs, ...}: {
    imports = with inputs.self.modules.darwin; [
      # services
      cachix
      ssh
      yubikey

      # lib/tools
      home-manager # This wires Home-Manager into the system
    ];

    nix = {
      inherit gc registry nixPath;
      settings = {
        auto-optimise-store = true;
        experimental-features = experimental-features;
      };
    };

    time = {
      timeZone = "Europe/Berlin";
    };

    nixpkgs.overlays = [
      (final: _prev: {
        stable = import inputs.nixpkgs-unstable {
          inherit (final) config;
          system = pkgs.stdenv.hostPlatform.system;
        };
      })
    ];
    environment.systemPackages = packages pkgs;
    documentation.doc.enable = false;
    system.stateVersion = stateVersion.darwin;
  };

  flake.modules.homeManager.system-default = {
    pkgs,
    config,
    ...
  }: {
    home.homeDirectory =
      if pkgs.stdenv.isDarwin
      then (lib.mkForce "/Users/${config.home.username}")
      else "/home/${config.home.username}";
    home.stateVersion = stateVersion.homeManager;
  };
}
