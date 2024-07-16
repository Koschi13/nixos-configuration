{ astronvim, pkgs, ... }:

{
  home = {
    sessionVariables = {
      VISUAL = "nvim";
    };

    packages = with pkgs; [
      gcc
      gnumake
    ];

    file = {
      "./.config/nvim/" = {
        source = builtins.fetchGit {
          url = "https://github.com/Koschi13/AstroNvim-template";
          # TODO: use flake input
          rev = "f89ab0a163dcf667121750c5bca0f097ec5f7b9a";
          shallow = true;
        };
        recursive = true;
      };
    };
  };
}
