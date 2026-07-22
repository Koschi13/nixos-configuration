{lib, ...}: {
  flake.modules.nixos.gpg = {pkgs, ...}: {
    programs.ssh.startAgent = lib.mkForce false;

    environment.systemPackages = with pkgs; [gnupg];
  };
}
