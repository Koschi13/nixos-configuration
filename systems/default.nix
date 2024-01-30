{ inputs, lib, config, pkgs, ... }:

{
  config = {
    nixpkgs = {
      overlays = [
      ];
      config = {
        allowUnfree = true;
      };
    };

    # Get ready for nix flakes
    nix = {
      # This will add each flake input as a registry
      # To make nix3 commands consistent with your flake
      registry = lib.mapAttrs (_: value: {flake = value;}) inputs;

      # This will additionally add your inputs to the system's legacy channels
      # Making legacy nix commands consistent as well, awesome!
      nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

      settings = {
        # Enable flakes and new 'nix' command
        experimental-features = "nix-command flakes";

        # Deduplicate and optimize nix store
        auto-optimise-store = true;
      };

      # Do some housekeeping
      gc = {
        automatic = true;
        dates = "daily";
        options = "--delete-older-than 30d";
      };
    };

    time = {
      timeZone = "Europe/Berlin";
      # Fix DualBoot time
      hardwareClockInLocalTime = true;
    };

    networking = {
      #
      # Set the hostname in the host specific config
      #
      networkmanager.enable = true;
    };

    services.xserver = {
      # Enable the X11 windowing system.
      enable = true;
      excludePackages = [ pkgs.xterm ];
    };

    programs.regreet.enable = true;
    services.greetd = {
      enable = true;
      settings = {
        initial_session = {
          user = "max";
          command = "$SHELL -l";
        };
      };
    };

    # Enable sound (pipewire)
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;  # For realtime acquisition
    security.polkit.enable = true;  # Needed for Hyprland/Sway
    # See https://github.com/hyprwm/Hyprland/issues/2727
    # Need for Swaylock to accept password
    security.pam.services.swaylock = {};
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      wireplumber.enable = true;
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.max = {
      isNormalUser = true;
      initialPassword = "P@ssw0rd";
      shell = pkgs.zsh;

      extraGroups = [
        # Enable ‘sudo’ for the user.
        "wheel"
        # Enable light control for the user
        "video"
        # Enalbe networkmanager control for the user
        "networkmanager"
      ];
    };

    # default package available to the system
    environment = {
      systemPackages = with pkgs; [
        git
        wget
        gnupg
	pcsclite
      ];

      # https://rycee.gitlab.io/home-manager/options.html#opt-programs.zsh.enableCompletion
      pathsToLink = [ "/share/zsh" ];
    };

    xdg = {
      portal = {
        enable = true;
        wlr.enable = true;

        # Fix warning which recently popped up
        # TODO: figure out if something needs to be specified here
        config.common.default = "*";

        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
          # Enable the hyprland portal (if using hyprland)
          # xdg-desktop-portal-hyprland
        ];
      };
    };

    programs = {
      zsh.enable = true;
      dconf.enable = true;
    };

    # YubiKey configuration
    services.udev.packages = [ pkgs.yubikey-personalization ];
    services.pcscd.enable = true;

    # Use GPG instead of SSH
    programs.ssh.startAgent = false;

    # Do not generate XML / HTML docs. This is a waste of space for most users and sometimes breaks.
    documentation.doc.enable = false;

    virtualisation = {
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    boot = {
      tmp.useTmpfs = true;
    };

    services.dbus.packages = with pkgs; [
      gnome3.gnome-keyring
      gcr
    ];
    services.gnome.gnome-keyring.enable = true;
  };
}
