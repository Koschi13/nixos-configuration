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

  # Settings shared by the `nixos` and `darwin` classes
  shared = {pkgs, ...}: {
    nix = {
      inherit registry nixPath;
      # Everything comes from the flake, `nixPath` points into the registry
      channel.enable = false;
      # Deduplicate the store on a timer instead of slowing down every build
      optimise.automatic = true;
      settings = {
        experimental-features = experimental-features;
        # Admins may use extra substituters and import unsigned paths
        trusted-users = ["@wheel" "@admin"];
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
        docker
        firmware
        logind
        gpg
        yubikey
        shell
        neovim

        # lib/tools
        home-manager # This wires Home-Manager into the system
      ]);

    # The single garbage collection policy of NixOS hosts. It cleans the system
    # and all user profiles, so neither `nix.gc` nor Home-Manager's `nh` clean.
    programs.nh = {
      enable = true;
      clean = {
        enable = true;
        dates = "daily";
        extraArgs = "--keep-since 10d --keep 3";
      };
    };

    networking = {
      networkmanager = {
        enable = true;
      };
    };

    nixpkgs.config.allowUnfree = true;

    boot.tmp.cleanOnBoot = true;

    # Kill the biggest memory hog of a user under pressure, before the whole
    # desktop freezes
    systemd.oomd.enableUserSlices = true;

    system.stateVersion = stateVersion.nixOs;
    programs.nix-ld.enable = true;
    # Replaced by nix-index of Home-Manager, both define the same shell hook
    programs.command-not-found.enable = false;
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

    # nix-darwin has no `programs.nh`, so macOS keeps the plain nix GC
    nix.gc = {
      automatic = true;
      options = "--delete-older-than 10d";
    };

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
      catppuccin
      nix-index
    ];

    home.packages = with pkgs; [
      ripgrep
      fd
      # Browse the dependency graph of a derivation
      nix-tree
      # Explain why two derivations differ
      nix-diff
    ];

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
