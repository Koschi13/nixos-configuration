{rootPath, ...}: let
  vars = import "${rootPath}/.secrets/git_vars.nix";
in {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      # Instead of using `git@github.com:<url>` use `vars.bshGit.host:<url>`
      "${vars.bshGit.host}" = {
        user = "git";
        hostname = vars.bshGit.hostname;
        identityFile = vars.bshGit.identityFile;
        identitiesOnly = true;
        IdentityAgent = "none";
      };
      "${vars.bsh.host}" = {
        user = "git";
        hostname = vars.bsh.hostname;
        port = vars.bsh.port;
        identityFile = vars.bsh.identityFile;
        identitiesOnly = true;
      };
    };
  };
}
