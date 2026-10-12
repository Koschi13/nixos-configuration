{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "alpha.lan" = {
        hostname = "alpha.lan";
        user = "max";
        identityFile = "~/.ssh/yubikey.pub";
      };
    };
  };

  home.file.".ssh/yubikey.pub" = {
    source = ./yubikey.pub;
  };
}
