{
  self,
  inputs,
  lib,
  ...
}: let
  username = "max";
in {
  flake.modules = lib.mkMerge [
    # Create the user in the system
    (self.factory.user {
      inherit username;
      uid = 1000;
      isAdmin = true;
    })
    {
      nixos.max = {
        users.users.${username}.group = "users";

        # Secrets of the Home-Manager aspects, read through `osConfig`
        age.secrets = {
          # `[user]` of the `gitdir:~/Git/HiQ/**` include of `git`
          git-hiq = {
            file = "${inputs.self}/secrets/git-hiq.age";
            owner = username;
          };
          # GLANCE_LOCATION of the weather widget of `glance`
          glance-env = {
            file = "${inputs.self}/secrets/glance-env.age";
            owner = username;
          };
        };
      };

      # darwin.max = {
      #   imports = with self.modules.darwin; [
      #   ];
      # };

      homeManager.max = {
        imports = with self.modules.homeManager; [
          system-desktop
        ];
      };
    }
  ];
}
