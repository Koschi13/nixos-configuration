{
  self,
  inputs,
  ...
}: let
  vars = import "${inputs.git-crypt-secrets}/git_vars.nix";
in {
  flake.modules.homeManager.git = {pkgs, ...}: {
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
      ];
    };
  };
}
