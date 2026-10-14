{lib, ...}: {
  flake.modules = {
    nixos.gpg = {pkgs, ...}: {
      programs.ssh.startAgent = lib.mkForce false;

      # pinentry-tty allows unlocking keys without a graphical session
      environment.systemPackages = with pkgs; [gnupg pinentry-tty];
    };
    homeManager.gpg = {pkgs, ...}: {
      home.packages = with pkgs; [pinentry-gnome3];
      programs = {
        gpg = {
          enable = true;
          publicKeys = [
            {
              source = ./925FFE9DE0563625C9990979FCD1C7696CB6672A.asc;
              trust = 5;
            }
          ];
        };
      };

      services = {
        gpg-agent = {
          enable = true;
          pinentry.package = pkgs.pinentry-gnome3;
          enableSshSupport = true;
        };
      };
    };
  };
}
