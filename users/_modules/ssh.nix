{
  rootPath,
  ...
}:
let
  vars = import "${rootPath}/.secrets/git_vars.nix";
in {
  programs.ssh = {
    enable = true;
    matchBlocks = {
      # Together with the git config this enables us to have a ssh config on a
      # directory basis.
      # See: https://superuser.com/a/366656
      "${vars.bshGit.host}" = {
        user = "git";
        hostname = vars.bshGit.hostname;
        identityFile = vars.bshGit.identityFile;
        identitiesOnly = true;
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
