{
  flake.modules = {
    # Generic SSH client setup. Hosts add their match blocks through
    # `programs.ssh.settings`, e.g. `hosts/epsilon [N]/users/max.nix`.
    homeManager.ssh = {
      # TODO: in conflict with openssh?
      programs.ssh = {
        enable = true;
        enableDefaultConfig = false;
      };

      # The public key of the YubiKey, so `identityFile` can select it from the
      # gpg-agent
      home.file.".ssh/yubikey.pub" = {
        source = ./yubikey.pub;
      };
    };
  };
}
