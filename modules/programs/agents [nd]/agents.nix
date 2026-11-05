{inputs, ...}: {
  flake.modules.homeManager.agents = {pkgs, ...}: let
    skills = import ./_mattpocockSkills {
      inherit pkgs;
      mattpocockSkills = inputs.mattpocock-skills;
    };
  in {
    programs.herdr.enable = true;
    programs.claude-code.enable = true;

    home.file.".agents/skills" = {
      source = "${skills}";
      recursive = true;
    };
  };
}
