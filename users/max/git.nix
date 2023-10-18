{ inputs, lib, config, pkgs, rootPath, ... }:

let

  vars = import rootPath + .secrets/git_vars.nix;

in {
  programs.git = {
    enable = true;
    userName = "Maximilian Konter";
    userEmail = "maximilian.konter@protonmail.com";
    signing.signByDefault = true;

    includes = [
      {
        condition = "gitdir:~/Git/Scandio";
        contents = {
          user = {
            name = vars.scandio.name;
            email = vars.scandio.email;
          };
        };
        commit = {
          gpgSign = false;
        };
      }

      {
        condition = "gitdir:~/Git/BSH";
        contents = {
          user = {
            name = vars.bsh.name;
            email = vars.bsh.email;
          };
        };
        commit = {
          gpgSign = false;
        };
      }
    ];
  };
}
