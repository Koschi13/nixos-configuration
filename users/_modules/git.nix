{
  pkgs,
  rootPath,
  ...
}: let
  vars = import "${rootPath}/.secrets/git_vars.nix";
in {
  home.packages = with pkgs; [
    git-autofixup
  ];

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
  };

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Maximilian Konter";
        email = "maximilian.konter@protonmail.com";
      };
      core = {
        fsmonitor = true;
        untrackedCache = true;
      };
      branch.sort = "-committerdate";
      rebase.autosquash = true;
      delta.navigate = true;
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      rerere.enable = true;
      push.followTags = true;
    };

    signing = {
      signByDefault = true;
      key = "FCD1C7696CB6672A";
      format = "openpgp";
    };

    includes = [
      {
        condition = "gitdir:~/Git/HiQ/**";
        contents = {
          user = {
            name = vars.hiq.name;
            email = vars.hiq.email;
          };
          commit.gpgsign = false;
          tag.gpgsign = false;
        };
      }

      {
        condition = "gitdir:~/Git/BSH/GitHub/**";
        contents = {
          user = {
            name = vars.bshGit.name;
            email = vars.bshGit.email;
          };
          commit.gpgsign = true;
          tag.gpgsign = true;
          user.signingkey = vars.bshGit.signingkey;
        };
      }

      {
        condition = "gitdir:~/Git/BSH/BitBucket/**";
        contents = {
          user = {
            name = vars.bsh.name;
            email = vars.bsh.email;
          };
          commit.gpgsign = true;
          tag.gpgsign = true;
          user.signingkey = vars.bsh.signingkey;
        };
      }
    ];
  };
}
