{self, ...}: {
  # TODO: secrets
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
    };
  };
}
