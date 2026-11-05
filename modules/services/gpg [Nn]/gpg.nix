{
  flake.modules = {
    nixos.gpg = {pkgs, ...}: {
      # pinentry-tty allows unlocking keys without a graphical session
      environment.systemPackages = with pkgs; [gnupg pinentry-tty];
    };
    homeManager.gpg = {
      lib,
      pkgs,
      ...
    }: {
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
          # Works without a graphical session, `system-desktop` overrides it
          pinentry.package = lib.mkDefault pkgs.pinentry-tty;
          enableSshSupport = true;
        };
      };
    };
  };
}
