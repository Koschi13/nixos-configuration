{ inputs, lib, config, pkgs, ... }:

{
  imports = [
    # Include the results of the hardware scan
    ./hardware-configuration.nix
  ];

  nixpkgs = {
    overlays = [
    ];
    config = {
      allowUnfree = true;
    };
  };

  # Make ready for nix flakes
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
  };

  time = {
    timeZone = "Europe/Berlin";
    # Fix DualBoot time
    hardwareClockInLocalTime = true;
  };


  networking = {
    hostName = "alpha";
    useDHCP = lib.mkDefault true;
    # Enable only specific interface (move to hardware.nix then)
    # interfaces.enp5s0.useDHCP = lib.mkDefault true;
  };

  services.xserver = {
    # Enable the X11 windowing system.
    enable = true;
    videoDrivers = ["nvidia"];

    # Enable GDM login
    displayManager = {
      gdm.enable = true;
      gdm.wayland = true;
    };

    # Enable Gnome desktop
    desktopManager = {
      gnome.enable = true;
    };
  };

  # Enable sound (pipewire)
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
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
    # Enable ‘sudo’ for the user.
    extraGroups = [ "wheel" ];
  };

  # default package available to the system
  environment.systemPackages = with pkgs; [
    wget
    git
  ];

  programs = {
    neovim.enable = true;
    neovim.viAlias = true;
    neovim.vimAlias = true;
  };
  environment.variables.EDITOR = "nvim"; 

  # YubiKey configuration
  services.udev.packages = [ pkgs.yubikey-personalization ];
  services.pcscd.enable = true;
  programs.ssh.startAgent = false;
  environment.shellInit = ''
    gpg-connect-agent /bye
    export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
  '';

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.05"; # Did you read the comment?
}
