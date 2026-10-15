{inputs, ...}: {
  flake.modules.homeManager.agents = {pkgs, ...}: let
    skills = import ./_mattpocockSkills {
      inherit pkgs;
      mattpocockSkills = inputs.mattpocock-skills;
    };
  in {
    home.file.".agents/skills" = {
      source = "${skills}";
      recursive = true;
    };
  };
}
