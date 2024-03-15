{ inputs, lib, config, pkgs, ... }:

{
  programs = {
    gpg = {
      enable = true;
      publicKeys = [{
        source = ./925FFE9DE0563625C9990979FCD1C7696CB6672A.asc;
        trust = 5;
      }];
    };
  };

  services = {
    gpg-agent = {
      enable = true;
      pinentryPackage = pkgs.pinentry-gnome3;
      enableSshSupport = true;
    };
  };
}
