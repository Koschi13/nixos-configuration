{self, ...}: {
  flake.modules.homeManager.git = {
    pkgs,
    osConfig,
    ...
  }: {
    imports = with self.modules.homeManager; [delta];

    home.packages = with pkgs; [
      git-autofixup
    ];

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
        # The `[user]` of HiQ, decrypted by agenix (see `nixos.max`)
        {
          condition = "gitdir:~/Git/HiQ/**";
          path = osConfig.age.secrets.git-hiq.path;
        }
        {
          condition = "gitdir:~/Git/HiQ/**";
          contents = {
            commit.gpgsign = false;
            tag.gpgsign = false;
          };
        }
      ];
    };
  };
}
