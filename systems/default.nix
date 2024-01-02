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
      # Set the hostname in the host specific config
      useDHCP = lib.mkDefault true;
    };

    services.xserver = {
      # Enable the X11 windowing system.
      enable = true;
      excludePackages = [ pkgs.xterm ];

      # Enable GDM login
      #displayManager = {
      #  gdm.enable = true;
      #  gdm.wayland = true;
      #};	

      # Enable Gnome desktop
      desktopManager = {
        gnome.enable = true;
      };
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

    environment.gnome.excludePackages = (with pkgs; [
      gnome-photos
      gnome-tour
      gnome-connections
      gnome-extension-manager
      gedit # text editor
    ]) ++ (with pkgs.gnome; [
      cheese # webcam tool
      gnome-music
      gnome-terminal
      epiphany # web browser
      geary # email reader
      evince # document viewer
      gnome-characters
      totem # video player
      tali # poker game
      iagno # go game
      hitori # sudoku game
      atomix # puzzle game
      yelp # gnome help
      simple-scan # document scanner
      gnome-calendar
      gnome-maps
      gnome-clocks
      gnome-contacts
      gnome-weather
      gnome-font-viewer
      gnome-logs
    ]);

    # Enable sound (pipewire)
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;  # For realtime acquisition
    security.polkit.enable = true;  # Needed for Hyprland
    # See https://github.com/hyprwm/Hyprland/issues/2727
    # Need for Swaylock to accept password
    security.pam.services.swaylock = {};
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.max = {
      isNormalUser = true;
      initialPassword = "P@ssw0rd";
      shell = pkgs.zsh;

      # Enable ‘sudo’ for the user.
      extraGroups = [ "wheel" ];
    };

    # default package available to the system
    environment = {
      systemPackages = with pkgs; [
        git
        wget
        gnupg
      ];

      # https://rycee.gitlab.io/home-manager/options.html#opt-programs.zsh.enableCompletion
      pathsToLink = [ "/share/zsh" ];

      #sessionVariables = {
      #  NIXOS_OZONE_WL = "1";
      #};
    };

    xdg = {
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-wlr
          xdg-desktop-portal-hyprland
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
  };
}
