{inputs, ...}: {
  flake.modules.homeManager.agents = {pkgs, ...}: let
    skills = import ./_mattpocockSkills {
      inherit pkgs;
      mattpocockSkills = inputs.mattpocockSkills;
    };
  in {
    home.file.".agents/skills" = {
      source = "${skills}";
      recursive = true;
    };
  };
}
