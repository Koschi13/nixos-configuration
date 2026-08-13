{
  flake.modules = {
    nixos.git-crypt = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [git-crypt];
    };

    darwin.git-crypt = {pkgs, ...}: {
      environment.systemPackages = with pkgs; [git-crypt];
    };
  };
}
