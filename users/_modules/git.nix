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
        # Had to be disable due to incompatibility with direnv:
        # https://discourse.nixos.org/t/builtins-getflake-breaks-if-git-core-fsmonitor-is-enabled/54916/4
        fsmonitor = false;
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
    ];
  };
}
