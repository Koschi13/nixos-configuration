{
  self,
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
