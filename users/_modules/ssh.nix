{...}: let
in {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
  };
}
