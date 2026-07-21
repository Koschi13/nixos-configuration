{lib, ...}: {
  flake.modules.nixos.gpg = {
    programs.ssh.startAgent = lib.mkForce false;
  };
}
